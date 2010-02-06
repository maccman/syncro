gem "supermodel"
gem "scriber"
require "supermodel"
require "scriber"

module Syncro
  class SyncroError < StandardError; end
  
  def klasses
    @klasses ||= []
  end
  
  def find_client(guid)
    return guid if guid.is_a?(Client)
    Client.find_or_create_by_guid(guid)
  end

  def connect(client, io)
    find_client(client).connect(io)
  end
  
  def receive(client, data)
    find_client(client).receive(data)
  end
  
  extend self
  
  module Model
    def self.included(base)
      Syncro.klasses << base
    end
  end
end

$: << File.dirname(__FILE__)

require "syncro/app"
require "syncro/client"
require "syncro/scribe_observer"
require "syncro/protocol/message"
require "syncro/protocol/message_buffer"
require "syncro/response"