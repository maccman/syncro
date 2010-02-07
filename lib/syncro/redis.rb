require "syncro/redis/client"
require "syncro/redis/scriber/scribe"

Syncro::Client = Syncro::Redis::Client
Syncro::Scriber::Scribe = Syncro::Redis::Scriber::Scribe