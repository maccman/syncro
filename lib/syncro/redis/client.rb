module Syncro
  module Redis
    class Client < Syncro::Client
      include SuperModel::Redis::Model
      indexes :uid
    end
  end
end