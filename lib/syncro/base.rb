module Syncro
  module Base
    def self.included(base)
      Syncro.klasses << base
      base.send :include, Scriber::Base
    end
  end
end