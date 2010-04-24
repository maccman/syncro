module Syncro
  class Client
    include SuperModel::Marshal::Model
    marshal :except => :connection
  end
  
  module Scriber
    class Scribe
      include SuperModel::Marshal::Model
    end
  end
end