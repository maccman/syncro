module Syncro
  module Base
    def self.included(base)
      Syncro.klasses << base
    end
  end
end