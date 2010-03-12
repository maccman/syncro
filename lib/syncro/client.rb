module Syncro
  class Client < SuperModel::Base
    include SuperModel::RandomID
    
    class << self
      def for(uid)
        find_or_create_by_uid(uid.to_s)
      end
    end
    
    attributes :uid, :connection, :last_scribe_id
        
    def connected?
      !!self.connection
    end
    
    def connect(connection)
      self.connection = connection
    end
    
    def disconnect
      buffer.clear
    end
    
    def sync(&block)
      app.sync(&block)
    end
    
    def add_scribe(scribe, &block)
      app.add_scribe(scribe, &block)
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
      return unless connected?
      if connection.respond_to?(:send_message)
        connection.send_message(message)
      elsif connection.respond_to?(:send_data)
        connection.send_data(message.serialize)
      else
        connection.write(message.serialize)
      end
    end
    
    def to_s
      (uid || id).to_s
    end
          
    def serializable_hash(options = {})
      options[:except] ||= []
      options[:except] << :connection
      super(options)
    end
    
    protected
      def app
        @app ||= App.new(self)
      end
    
      def buffer
        @buffer ||= Protocol::MessageBuffer.new
      end
  end
end