module Syncro
  module Scriber
    class Observer
      include Singleton
      
      class << self
        def disabled_clients
          @disabled_clients ||= []
        end
        
        def disable(clients, &block)
          @disabled_clients = clients
          yield
          @disabled_clients = nil
        end
      end
   
      def after_create(rec)
        rec.class.record(
          :create, 
          rec.attributes, 
          active_clients(rec)
        )
      end
      
      def after_update(rec)
        changed_to = rec.previous_changes.inject({}) {|hash, (key, (from, to))| 
          hash[key] = to
          hash 
        }
        rec.class.record(
          :update, 
          [rec.id, changed_to], 
          active_clients(rec)
        )
      end
      
      def after_destroy(rec)
        rec.class.record(
          :destroy, 
          rec.id, 
          active_clients(rec)
        )
      end
            
      def update(observed_method, object) #:nodoc:
        # Sending to clients is disabled
        return unless object.scribe_clients
        # Clients specified, but no non-disabled clients to send too
        return if object.scribe_clients.any? && active_clients(object).empty?
        send(observed_method, object) if respond_to?(observed_method)
      end

      def observed_class_inherited(subclass) #:nodoc:
        subclass.add_observer(self)
      end
      
      protected
        def active_clients(object)
          object.scribe_clients - self.class.disabled_clients
        end
    end
  end
end