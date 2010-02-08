module Syncro
  module Redis
    module Scriber
      class Scribe < Scriber::Scribe
        include SuperModel::Redis::Model
        
        class << self
          def since(client, id)
            results  = redis.zrange(redis_key(:clients, client), id, -1)
            results += redis.zrange(redis_key(:clients, :all),   id, -1)
            results.map {|i| 
              result = self.new(:id => i) 
              result.redis_get
              result
            }
          end

          def all(client)
            since(client, 0)
          end
        end
        
        serialize :data

        after_save :index_clients

        protected
          def index_clients
            if clients.blank?
              redis.zadd(redis_key(:clients, :all), id, id)
            else
              clients.each {|client|
                redis.zadd(redis_key(:clients, client), id, id)
              }              
            end
          end
      end
    end
  end
end