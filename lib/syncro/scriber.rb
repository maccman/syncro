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
  end
end