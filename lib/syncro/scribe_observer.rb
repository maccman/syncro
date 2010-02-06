module Syncro
  class ScribeObserver < ActiveModel::Observer
    observe "Scriber::Scribe"
    
    def after_save(scribe)
      Client.all.each {|c| c.add_scribe(scribe) }
    end
  end
end

SuperModel::Base.observers = Syncro::ScribeObserver