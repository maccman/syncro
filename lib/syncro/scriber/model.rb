module Syncro
  module Scriber
    module Model
      def self.included(base)
        Scriber.klasses << base
        base.extend ClassMethods
        Observer.instance.add_observer!(base)
      end
      
      def scribe_clients
        :all
      end

      module ClassMethods
        def scribe_play(scribe) #:nodoc:
          return unless scribe_authorized?(scribe)
          Observer.from(scribe.from_client) do
            case scribe.type.to_sym
            when :create  then create(scribe.data)
            when :update  then update(scribe.data[0], scribe.data[1])
            when :destroy then destroy(scribe.data[0])
            else
              method = "scribe_play_#{scribe.type}"
              send(method) if respond_to?(method)
            end
          end
        end

        def record(type, options = {})
          options.merge!({
            :klass   => self, 
            :type    => type
          })
          Scribe.create(options)
        end
        
        def scribe_authorized?(scribe)
          true
        end
      end
    end
  end
end