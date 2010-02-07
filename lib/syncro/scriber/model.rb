module Syncro
  module Scriber
    module Model
      def self.included(base)
        Scriber.klasses << base
        base.extend ClassMethods
        base.add_observer(Observer.instance)
      end
      
      def scribe_clients
        []
      end

      module ClassMethods
        def scribe_play(scribe) #:nodoc:
          return unless scribe_authorized?(scribe)
          Observer.disable(scribe.clients) do
            case scribe.type.to_sym
            when :create  then create(scribe.data)
            when :update  then update(scribe.data[0], scribe.data[1])
            when :destroy then destroy(scribe.data)
            else
              method = "scribe_play_#{scribe.type}"
              send(method) if respond_to?(method)
            end
          end
        end

        def record(type, data = nil, clients = [])
          options = {
            :klass   => self, 
            :type    => type, 
            :data    => data,
            :clients => clients
          }
          Scribe.create(options)
        end
        
        def scribe_authorized?(scribe)
          true
        end
      end
    end
  end
end