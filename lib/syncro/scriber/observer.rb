module Syncro
  module Scriber
    class Observer
      include Singleton
      class_attribute :observed_methods
      self.observed_methods = []
      
      class << self
        # So we can use this Observer on ActiveRecord classes
        def method_added(method) #:nodoc:
          return unless defined?(ActiveRecord)
          self.observed_methods += [method] if ActiveRecord::Callbacks::CALLBACKS.include?(method.to_sym)
        end
        
        def from_scribe
          @scribe
        end
        
        def with_scribe(scribe, &block)
          @scribe = scribe
          result  = yield
          @scribe = nil
          result
        end
        
        def disable(&block)
          @disabled ||= 0
          @disabled += 1
          result = yield
          @disabled -= 1
          result
        end
        
        def disabled?
          @disabled && @disabled > 0
        end
      end
   
      def after_create(rec)
        rec.class.record(
          :create, 
          :data        => rec.attributes, 
          :client_uids => rec.scribe_clients,
          :from_scribe => self.class.from_scribe
        )
      end
      
      def after_update(rec)
        changed_to = rec.changes.inject({}) {|hash, (key, (from, to))| 
          hash[key] = to
          hash 
        }
        return if changed_to.empty?
        rec.class.record(
          :update, 
          :data        => [rec.id, changed_to], 
          :client_uids => rec.scribe_clients,
          :from_scribe => self.class.from_scribe
        )
      end
      
      def after_destroy(rec)
        rec.class.record(
          :destroy, 
          :data        => [rec.id], 
          :client_uids => rec.scribe_clients,
          :from_scribe => self.class.from_scribe
        )
      end
      
      def update(observed_method, object) #:nodoc:
        return unless respond_to?(observed_method)
        return unless allowed?(object, observed_method)
        return if object.scribe_clients.blank?
        send(observed_method, object) 
      end

      def observed_class_inherited(subclass) #:nodoc:
        subclass.add_observer(self)
      end
      
      def add_observer!(klass) #:nodoc:
        klass.add_observer(self)
        
        if defined?(ActiveRecord) && ActiveRecord::Base > klass
          self.class.observed_methods.each do |method|
            callback = :"_notify_observers_for_#{method}"
            if (klass.instance_methods & [callback, callback.to_s]).empty?
              klass.class_eval "def #{callback}; notify_observers(:#{method}); end"
              klass.send(method, callback)
            end
          end
        end
      end
      
      protected
        def allowed?(object, observed_method)
          return false if self.class.disabled?
          return false if object.scribe_disabled?
          
          method = observed_method.to_s
          method.gsub!(/before_|after_/, "")
          
          options = object.class.scribe_options
          
          options[:only]   = Array.wrap(options[:only]).map { |n| n.to_s }
          options[:except] = Array.wrap(options[:except]).map { |n| n.to_s }
          
          if options[:only].any?
            return false unless options[:only].include?(method)
          end
          
          if options[:except].any?
            return false if options[:except].include?(method)
          end
          true
        end
    end
  end
end