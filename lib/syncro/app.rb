module Syncro
  class App
    attr_reader :session, :message
    
    def initialize(session)
      @session = session
    end
    
    def client
      @client ||= @session.client.reload
    end
    
    def call(message)
      @client  = nil
      @message = message
      method   = "invoke_#{message.type}"
      send(method) if respond_to?(method)
    end
    
    def sync
      invoke(:sync, :from => client.last_scribe_id) do |resp|
        scribes = resp.map {|s| 
          scribe = Scriber::Scribe.new(s)
          scribe.from_client  = client
          scribe.from_session = session
          scribe
        }
        allowed_scribes = scribes.select {|s| 
          allowed_klasses.include?(s.klass) 
        }
        allowed_scribes.each {|s| s.play }
        
        if scribes.any?
          client.last_scribe_id = scribes.last.id
        end
        client.synced = true
        client.save!
        
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
    
    def rpc(klass, method, *args, &block)
      invoke(
        :rpc,
        :klass  => klass,
        :method => method,
        :args   => args,
        &block
      )
    end

    protected    
      def invoke_sync
        scribes = begin
          if message[:from].present?
            Scriber::Scribe.since(client, message[:from])
          else
            Scriber::Scribe.for_client(client)
          end
        end
        # Otherwise clients get duplicate scribes
        scribes.reject! {|s| s.from_client == client }
        respond(scribes)
      end
      
      def invoke_add_scribe
        scribe = Scriber::Scribe.new(message[:scribe])
        scribe.from_client  = client
        scribe.from_session = session
        unless allowed_klasses.include?(scribe.klass)
          error(403)
          return
        end
        scribe.play
        respond(true)
        client.update_attribute(
          :last_scribe_id, 
          scribe.id
        )
      rescue => e
        error
        raise(e)
      end
    
      def invoke_rpc
        RPC.invoke(session, message)
      rescue => e
        error
        raise(e)
      end
      
      def invoke_response
        Response.call(session.object_id, message.id, message[:result])
      end
      
      def invoke_error
        raise InvokeError.new(message[:code])
      end
      
      def invoke_noop
        respond true
      end
            
      def allowed_klasses
        Syncro.klasses.map(&:to_s)
      end
      
    public
      def invoke(type, hash = {}, &block)
        message      = Protocol::Message.new
        message.type = type
        message.merge!(hash)
        message.id   = session.msg_id
        Response.expect(session.object_id, message.id, &block)
        session.send_message(message)
      end
    
      def respond(res = nil)
        message      = Protocol::Message.new
        message.type = :response
        message.id   = @message.id if @message
        message[:result] = res
        session.send_message(message)
      end
      
      def error(code = 0)
        message = Protocol::Message.new
        message.type = :error
        message[:code] = code
        session.send_message(message)
      end
  end
end