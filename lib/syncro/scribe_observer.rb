module Syncro
  class ScribeObserver < ActiveModel::Observer
    observe "Scriber::Scribe"
    
    def after_save(scribe)
      clients = []
      if scribe.clients
        clients = scribe.clients.map {|guid|
          Client.find_or_create_by_guid(guid)
        }
      else
        clients = Client.all
      end
      clients = clients.select(&:connected?)
      clients.each {|c| c.add_scribe(scribe) }
    end
  end
end

SuperModel::Base.observers = Syncro::ScribeObserver