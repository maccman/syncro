module Syncro
  module Scriber
    module Base
      def self.included(base)
        Scriber.klasses << base
        base.extend ClassMethods
      end

      module ClassMethods
        def record(type, options = {})
          options.merge!({
            :klass   => self, 
            :type    => type
          })
          Scribe.create(options)
        end
      end
    end
  end
end