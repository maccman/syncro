module Syncro
  module RPC
    def klasses
      @klasses ||= []
    end
    module_function :klasses
    
    def invoke(app, message)
      unless klasses.include?(message[:klass])
        app.error(404)
      end
      
      klass = message[:klass].constantize
      
      unless klass.respond_to?(message[:method])
        app.error(405)
      end
      
      result = klass.send(message[:method], *message[:args])
      app.respond(result)
    end
    module_function :invoke
        
    module Expose
      def self.included(base)
        RPC.klasses << base.name
      end      
    end
  end
end