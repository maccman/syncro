module Syncro
  module Scriber        
    def klasses
      @klasses ||= []
    end
    module_function :klasses
  end
end