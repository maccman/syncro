gem "supermodel"
gem "scriber"
require "supermodel"
require "scriber"

module Syncro
  class SyncroError < StandardError; end
  
  def klasses
    @klasses ||= []
  end

  def connect(client, io)
    unless client.respond_to?(:receive_data)
      client = Client.find_by_guid!(client)
    end
    client.connect(io)
  end
  
  def receive(client, data)
    unless client.respond_to?(:receive_data)
      client = Client.find_by_guid!(client)
    end
    client.receive(data)
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
require "syncro/server"
require "syncro/scribe_observer"
require "syncro/protocol/message"
require "syncro/protocol/message_buffer"
