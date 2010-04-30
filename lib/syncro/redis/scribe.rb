module Syncro
  module Redis
    class Syncro::Scriber::Scribe
      include SuperModel::Redis::Model
      
      class << self
        def since(client, id)
          items  = redis.zrangebyscore(redis_key(:clients, client), "(#{id}", "+inf")
          items += redis.zrangebyscore(redis_key(:clients, :all),   "(#{id}", "+inf")
          items  = from_ids(items)
          items  = items.reject {|item|
            item.from_client == client.to_s
          }
          items
        end

        def for_client(client)
          since(client, 0)
        end
      end
      
      serialize :data, :clients

      after_save :index_clients

      protected
        def index_clients
          if clients.blank?
            redis.zadd(self.class.redis_key(:clients, :all), id, id)
          else
            clients.each {|client|
              redis.zadd(self.class.redis_key(:clients, client), id, id)
            }
          end
        end
    end
  end
end