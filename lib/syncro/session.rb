module Syncro
  class Session
    class << self
      def records
        @records ||= []
      end
      
      def find(id)
        id = Integer(id) # Only integer IDs
        records.find {|r| r.id == id }
      end
      
      def for_client(client)
        records.select {|r| r.client == client }
      end
    end
    
    delegate :synced?, :to => :client
    delegate :sync, :add_scribe, :rpc, :to => :app
    
    attr_reader   :connection
    attr_accessor :client
    
    def initialize(connection, client = nil)
      @connection = connection
      self.client = client
      self.class.records << self
    end
    
    def client
      @client || raise("Client not set")
    end
    
    def disconnect
      buffer.clear
      self.class.records.delete(self)
    end
    
    def receive_data(data)
      buffer << data
      buffer.messages.each do |msg|
        receive_message(msg)
      end
    end
    
    def receive_message(data)
      message = begin
        case data
        when String
          Protocol::Message.fromJSON(data)
        when Protocol::Message
          data
        else
          Protocol::Message.new(data)
        end
      end
      app.call(message)
    end
    
    def send_message(message)
      if connection.respond_to?(:send_message)
        connection.send_message(message.to_json)
      elsif connection.respond_to?(:send_data)
        connection.send_data(message.serialize)
      else
        connection.write(message.serialize)
      end
    end
    
    def uptodate!
      rpc("Syncro::RPC::Default", :last_scribe_id) do |id|
        self.client.last_scribe_id = id
        self.client.synced = true
        self.client.save!
      end
    end
    
    def msg_id
      @msg_id ||= 0
      @msg_id += 1
    end
    
    def app
      @app ||= App.new(self)
    end
    
    def id
      self.object_id
    end
    
    def ==(other)
      other.equal?(self) || (other.instance_of?(self.class) && other.id == id)
    end

    def eql?(other)
      self == other
    end
    
    protected
      def buffer
        @buffer ||= Protocol::MessageBuffer.new
      end
  end
end