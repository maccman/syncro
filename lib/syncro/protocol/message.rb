module Syncro
  module Protocol
    class Message < HashWithIndifferentAccess
      def self.fromJSON(str)
      	self.new(JSON.parse(str))
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
        data = self.to_json
        [data.length].pack('n') + data
      end    
    end
  end
end
