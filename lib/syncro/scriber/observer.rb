module Syncro
  module Scriber
    class Observer
      include Singleton
      class_attribute :observed_methods
      self.observed_methods = []
      
      class << self
        def method_added(method)
          return unless defined?(ActiveRecord)
          self.observed_methods += [method] if ActiveRecord::Callbacks::CALLBACKS.include?(method.to_sym)
        end
        
        def from_client
          @from_client
        end
        
        def from(client, &block)
          @from_client = client
          result = yield
          @from_client = nil
          result
        end
      end
   
      def after_create(rec)
        rec.class.record(
          :create, 
          :data        => rec.attributes, 
          :clients     => active_clients(rec),
          :from_client => from_client
        )
      end
      
      def after_update(rec)
        changed_to = rec.changes.inject({}) {|hash, (key, (from, to))| 
          hash[key] = to
          hash 
        }
        rec.class.record(
          :update, 
          :data        => [rec.id, changed_to], 
          :clients     => active_clients(rec),
          :from_client => from_client
        )
      end
      
      def after_destroy(rec)
        rec.class.record(
          :destroy, 
          :data        => [rec.id], 
          :clients     => active_clients(rec),
          :from_client => from_client
        )
      end
      
      def update(observed_method, object) #:nodoc:
        # Is sending to clients disabled, or no clients specified?
        return unless scribe_clients(object)
        # Clients specified, but no non-disabled clients to send too
        return if scribe_clients(object).any? && active_clients(object).empty?
        send(observed_method, object) if respond_to?(observed_method)
      end

      def observed_class_inherited(subclass) #:nodoc:
        subclass.add_observer(self)
      end
      
      def add_observer!(klass)
        klass.add_observer(self)
        
        # For ActiveRecord
        self.class.observed_methods.each do |method|
          callback = :"_notify_observers_for_#{method}"
          if (klass.instance_methods & [callback, callback.to_s]).empty?
            klass.class_eval "def #{callback}; notify_observers(:#{method}); end"
            klass.send(method, callback)
          end
        end
      end
      
      protected
        def from_client
          self.class.from_client
        end
        
        def scribe_clients(object)
          clients = object.scribe_clients
          case clients
          when :all
            []
          when Array
            clients.empty? ? false : clients
          else
            false
          end
        end
      
        def active_clients(object)
          scribe_clients(object) - [from_client]
        end
    end
  end
end