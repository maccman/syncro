module Syncro
  class Client < SuperModel::Base
    include SuperModel::RandomID
    
    class << self
      def for(uid)
        find_or_create_by_uid(uid.to_s)
      end
    end
    
    attributes :uid, :last_scribe_id, :synced
            
    def sessions
      Session.for_client(self)
    end
    
    def scribes
      Scriber::Scribe.for_client(self)
    end
  end
end