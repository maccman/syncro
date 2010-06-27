module Syncro
  module Redis
    class Syncro::Client
      include SuperModel::Redis::Model
      indexes :uid
    end
  end
end