module Syncro
  module Redis
    class Client < Syncro::Client
      include SuperModel::Redis
      indexes :uid
    end
  end
end