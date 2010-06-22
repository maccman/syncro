module Syncro
  module Scriber        
    def klasses
      @klasses ||= []
    end
    module_function :klasses
    
    def disable(&block)
      Observer.disable(&block)
    end
    module_function :disable
    
    def active?
      !!Observer.from_client
    end
    module_function :active?
  end
end