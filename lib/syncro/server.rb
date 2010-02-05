module Syncro
  class Server < Client
    before_save :set_guid
    
    def set_guid
      self.guid = "server"
    end    
  end
end