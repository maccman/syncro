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