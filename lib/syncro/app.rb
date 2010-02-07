module Syncro
  class App
    attr_reader :client, :message
    
    def initialize(client)
      @client = client
    end
    
    def call(message)
      @message = message
      method   = "invoke_#{message.type}"
      send(method) if respond_to?(method)
    end
    
    def sync
      invoke(:sync, :from => client.last_scribe.try(:id)) {|resp|
        scribes = resp.map {|s| Scriber::Scribe.new(s) }
        client.last_scribe = scribes.last
        scribes = scribes.select {|s| allowed_klasses.include?(s.klass) }
        scribes.each {|s| s.play }
      }
    end
    
    def add_scribe(scribe)
      invoke(:add_scribe, :scribe => scribe)
    end

    protected    
      def invoke_sync
        result = begin
          if message[:from]
            Scriber::Scribe.since(client, message[:from])
          else
            Scriber::Scribe.all(client)
          end
        end
        respond(result)
      end
      
      def invoke_add_scribe
        scribe = Scriber::Scribe.new(message[:scribe])
        return unless allowed_klasses.include?(scribe)
        scribe.play
      end
    
      def invoke_response
        Response.call(client, message[:result])
      end
      
      def allowed_klasses
        Syncro.klasses.map(&:to_s)
      end
      
      def invoke(type, hash = {}, &block)
        message = Protocol::Message.new
        message.type = type
        message.merge!(hash)
        Response.expect(client, &block)
        client.send_message(message)
      end
    
      def respond(res)
        message = Protocol::Message.new
        message.type = :response
        message[:result] = res
        client.send_message(message)
      end
  end
end
