module Syncro
  class Client < SuperModel::Base
    include SuperModel::Persist::Model
    
    attributes :guid, :last_scribe
    validates_presence_of :guid
    
    attr_reader :connection
    
    def connected?
      !!@connection
    end
    
    def connect(connection)
      @connection = connection
    end
    
    def sync
      app.sync
    end
    
    def add_scribe(scribe)
      app.add_scribe(scribe)
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
      return unless connection
      if connection.respond_to?(:send_message)
        connection.send_message(message)
      elsif connection.respond_to?(:send_data)
        # EventMachine
        connection.send_data(message.serialize)
      else
        connection.write(message.serialize)
      end
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
