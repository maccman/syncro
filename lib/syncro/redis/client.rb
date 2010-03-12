module Syncro
  module Redis
    class Syncro::Client
      include SuperModel::Redis::Model
      indexes :uid
            
      # We need to hold the current connections
      # in memory (as they can't be serialized).
      
      class_attribute :connections
      self.connections = {}
      
      def connection
        self.class.connections[self.id]
      end
      
      def connect(connection)
        return unless self.id
        self.class.connections[self.id] = connection
      end
      
      def disconnect
        self.buffer.clear
        self.class.connections.delete(self.id)
      end
    end
  end
end