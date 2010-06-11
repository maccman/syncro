module Syncro
  module Protocol
    class Message < HashWithIndifferentAccess
      def self.fromJSON(str)
      	self.new(ActiveSupport::JSON.decode(str))
      end

      def type
      	self[:type].try(:to_sym)
      end
      
      def type=(val)
      	self[:type] = val
      end
      
      def id
        self[:id]
      end

      def id=(val)
        self[:id] = val
      end
      
      def serialize
        data = ActiveSupport::JSON.encode(self)
        [data.length].pack('n') + data
      end    
    end
  end
end
