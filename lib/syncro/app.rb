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
          scribe.from_client = client.to_s
          scribe
        }
        allowed_scribes = scribes.select {|s| 
          allowed_klasses.include?(s.klass) 
        }
        allowed_scribes.each {|s| s.play }
        
        if scribes.any?
          client.update_attribute(
            :last_scribe_id, 
            scribes.last.id
          )
        end
        yield if block_given?
      end
    end
    
    def add_scribe(scribe, &block)
      invoke(
        :add_scribe, 
        :scribe => scribe, 
        &block
      )
    end

    protected    
      def invoke_sync
        result = begin
          if message[:from]
            Scriber::Scribe.since(client, message[:from])
          else
            Scriber::Scribe.for_client(client)
          end
        end
        respond(result)
      end
      
      def invoke_add_scribe
        scribe = Scriber::Scribe.new(message[:scribe])
        scribe.from_client = client.to_s
        return unless allowed_klasses.include?(scribe.klass)
        scribe.play
        respond(true)
        client.update_attribute(
          :last_scribe_id, 
          scribe.id
        )
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
