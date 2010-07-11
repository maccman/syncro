#!/usr/bin/env ruby
require File.expand_path('../config/environment',  __FILE__)
require 'cramp'
require 'cramp/controller'

Cramp::Controller::Websocket.backend = :thin

class SyncroWebSocket < Cramp::Controller::Websocket
  on_start  :post_init
  on_finish :unbind
  on_data   :receive_message
    
  alias_method :send_message, :render
  
  def post_init
    @client  = ::Syncro::Client.new
    @session = ::Syncro::Session.new(self, @client)
  end

  def receive_message(data)
    @session.receive_message(data)
  rescue => e
    @session.app.error
    puts "#{e}\n\t" + e.backtrace.join("\n\t")
  end
  
  def unbind
    @session.disconnect
  end  
end

Thin::Logging.trace = true

map "/" do
  use Rack::CommonLogger  
  run SyncroWebSocket
end