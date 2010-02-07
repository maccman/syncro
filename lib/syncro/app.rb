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
      invoke(:sync, :from => client.last_scribe_id) do |resp|
        scribes = resp.map {|s| 
          scribe = Scriber::Scribe.new(s)
          scribe.clients = []
          scribe.clients << client.to_s
          scribe
        }
        allowed_scribes = scribes.select {|s| allowed_klasses.include?(s.klass) }
        allowed_scribes.each {|s| s.play }
        
        if scribes.any?
          client.update_attribute(
            :last_scribe_id, 
            scribes.last.id
          )
        end
      end
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
      ensure
        respond
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
    
      def respond(res = nil)
        message = Protocol::Message.new
        message.type = :response
        message[:result] = res
        client.send_message(message)
      end
  end
end
