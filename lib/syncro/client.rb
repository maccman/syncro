module Syncro
  class Client < SuperModel::Base
    include SuperModel::Persist::Model
    
    attributes :guid, :last_scribe
    validates_presence_of :guid
    
    attr_reader :connection
    
    def receive(data)
      buffer << data
      buffer.messages.each do |msg|
        app.call(msg)
      end
    end
    
    def connect(io)
      @connection = io
      app.sync
    end
    
    def transmit(message)
      return unless connection
      if connection.respond_to?(:send_data)
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
