module Syncro
  module Redis
    class Syncro::Scriber::Scribe
      include SuperModel::Redis::Model
      
      class << self
        def since(client, scribe_id)
          items  = redis.zrangebyscore(redis_key(:clients, client.id), "(#{scribe_id}", "+inf")
          items += redis.zrangebyscore(redis_key(:clients, :all),   "(#{scribe_id}", "+inf")
          items  = from_ids(items)
          items
        end

        def for_client(client)
          since(client, 0)
        end
      end
      
      serialize :data, :client_ids

      after_save :index_clients

      protected
        def index_clients
          if to_all
            redis.zadd(self.class.redis_key(:clients, :all), id, id)
          else
            client_ids.each {|client_id|
              redis.zadd(self.class.redis_key(:clients, client_id), id, id)
            }
          end
        end
    end
  end
end