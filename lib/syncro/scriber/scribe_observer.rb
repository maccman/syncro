module Syncro
  module Scriber
    class ScribeObserver
      include Singleton
    
      def after_create(scribe)
        sessions = scribe.to_sessions
        sessions.each {|c| c.add_scribe(scribe) }
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