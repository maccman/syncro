module Syncro
  class ScribeObserver < ActiveModel::Observer
    observe "Scriber::Scribe"
    
    def after_save(scribe)
    end
  end
end

SuperModel::Base.observers = Syncro::ScribeObserver