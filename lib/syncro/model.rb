module Syncro
  module Model
    def self.included(base)
      base.send :include, Base
      base.send :include, Scriber::Model
    end
  end
end