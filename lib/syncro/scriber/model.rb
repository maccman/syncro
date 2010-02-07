module Syncro
  module Scriber
    module Model
      def self.included(base)
        Scriber.klasses << base
        base.extend ClassMethods
        base.add_observer(Observer.instance)
      end

      module ClassMethods
        def scribe_play(scribe) #:nodoc:
          Observer.disable(scribe.clients) do
            case scribe.type
            when :create  then create(scribe.data)
            when :destroy then destroy(scribe.data)
            when :update  then update(scribe.data)
            else
              method = "scribe_play_#{type}"
              send(method) if respond_to?(method)
            end
          end
        end

        def scribe_clients
          []
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
      end
    end
  end
end