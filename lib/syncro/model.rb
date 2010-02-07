module Syncro
  module Model
    def self.included(base)
      Syncro.klasses << base
      base.send :include, Scriber::Model
    end
  end
end