module Syncro
  class App
    attr_reader :client, :message
    
    def initialize(client)
      @client = client
    end
    
    def call(message)
      @message = message
      method   = "invoke_#{message.type}"
      send(method)
    rescue NoMethodError
    end
    
    def sync
      invoke(:sync, :from => client.last_scribe.try(:id)) {|resp|
        scribes = resp.map {|s| Scribe.new(s) }
        client.last_scribe = scribes.last
        scribes = scribes.select {|s| 
          Syncro.klasses.include?(s.klass) 
        }
        scribes.each {|s| s.play }
      }
    end
    
    def add_scribe(scribe)
      invoke(:add_scribe, scribe)
    end

    protected    
      def invoke_sync
        result = begin
          if message[:from]
            Scribe.since(message[:from])
          else
            Scribe.all
          end
        end
        respond(result)
      end
      
      def invoke_add_scribe
        
      end
    
      def invoke_response
        Reponse.call(client, message[:result])
      end
      
      def invoke(type, hash = {}, &block)
        message = Protocol::Message.new
        message.type = type
        message.merge!(hash)
        Reponse.expect(client, &block)
        client.transmit(message)
      end
    
      def respond(res)
        message = Protocol::Message.new
        message.type = :response
        message[:result] = res
        client.transmit(message)
      end
  end
end
