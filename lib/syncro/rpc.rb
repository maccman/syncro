module Syncro
  module RPC
    def klasses
      @klasses ||= []
    end
    module_function :klasses
    
    def invoke(session, message)
      unless klasses.include?(message[:klass])
        session.app.error(404)
        return
      end
      
      klass = message[:klass].constantize
      
      unless klass.respond_to?(message[:method])
        session.app.error(405)
        return
      end
      
      result = klass.rpc_invoke(session, message[:method], *message[:args])
      session.app.respond(result)
    end
    module_function :invoke
        
    module Expose
      def self.included(base)
        base.extend ClassMethods
        RPC.klasses << base.name
      end
      
      module ClassMethods
        def rpc_invoke(session, method, *args)
          send(method, *args)
        end
      end
    end
    
    module Default
      include Expose
      extend self
      
      def rpc_invoke(session, method, *args)
        args.unshift(session)
        send(method, *args)
      end
      
      def last_scribe_id(session)
        scribes = session.client.scribes
        return 0 if scribes.empty?
        scribes.last.id
      end
    end
  end
end