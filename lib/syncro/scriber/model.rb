module Syncro
  module Scriber
    module Model
      def self.included(base)
        base.send :include, Base
        base.extend ClassMethods
        Observer.instance.add_observer!(base)
      end

      module ClassMethods
        def scribe_play(scribe) #:nodoc:
          unless scribe_authorized?(scribe)
            raise "Unauthorised Scribe"
          end
          Observer.from(scribe.from_client) do
            method = "scribe_play_#{scribe.type}"
            send(method, scribe) if respond_to?(method)
          end
        end
        
        def scribe_play_create(scribe)
          create!(scribe.data)
        end
        
        def scribe_play_update(scribe)
          record = find(scribe.data[0])
          record.update_attributes!(scribe.data[1])
          record
        end
        
        def scribe_play_destroy(scribe)
          destroy(scribe.data[0])
        end
        
        def scribe_authorized?(scribe)
          true
        end
        
        def scribe_options(value = nil)
          @scribe_options = value if value
          @scribe_options ||= {}
          @scribe_options
        end
        alias_method :scribe_options=, :scribe_options
      end
    end
  end
end