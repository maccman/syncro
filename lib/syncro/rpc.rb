module Syncro
  module RPC
    def klasses
      @klasses ||= []
    end
    module_function :klasses
    
    def invoke(client, message)
      unless klasses.include?(message[:klass])
        client.app.error(404)
        return
      end
      
      klass = message[:klass].constantize
      
      unless klass.respond_to?(message[:method])
        client.app.error(405)
        return
      end
      
      result = klass.rpc_invoke(client, message[:method], *message[:args])
      client.app.respond(result)
    end
    module_function :invoke
        
    module Expose
      def self.included(base)
        base.extend ClassMethods
        RPC.klasses << base.name
      end
      
      module ClassMethods
        def rpc_invoke(client, method, *args)
          send(method, *args)
        end
      end
    end
    
    module Default
      include Expose
      extend self
      
      def rpc_invoke(client, method, *args)
        args.unshift(client)
        send(method, *args)
      end
      
      def last_scribe_id(client)
        client.last_scribe_id
      end
    end
  end
end