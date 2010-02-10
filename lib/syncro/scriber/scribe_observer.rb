module Syncro
  module Scriber
    class ScribeObserver
      include Singleton
    
      def after_create(rec)
        if rec.clients.blank?
          clients = Client.all.reject {|client| 
            client.to_s == rec.from_client
          }
        else
          clients = rec.clients.map {|r| Client.for(r) }
        end
        
        clients.each {|c| c.add_scribe(rec) }
      end
    
      def update(observed_method, object) #:nodoc:
        send(observed_method, object) if respond_to?(observed_method)
      end

      def observed_class_inherited(subclass) #:nodoc:
        subclass.add_observer(self)
      end
    end
  end
end

Syncro::Scriber::Scribe.add_observer(
  Syncro::Scriber::ScribeObserver.instance
)