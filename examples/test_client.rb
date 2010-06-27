$: << File.expand_path(File.join(File.dirname(__FILE__), ".."))
require File.join(*%w[lib syncro])

require "eventmachine"
require "supermodel"

class Test < SuperModel::Base
  include SuperModel::Marshal::Model
  include Syncro::Model
  
  attributes :name
end

class MyConnection < EM::Connection
  def connection_completed
    @client  = Syncro::Client.for(:server)
    @session = Syncro::Session.new(self, @client)
    @session.sync
  end
  
  def receive_data(data)
    puts "Received: #{data}"
    @session.receive_data(data)
  end
  
  def send_data(data)
    puts "Sending: #{data}"
    super(data)
  end
  
  def unbind
    @session.disconnect
  end
end

require "syncro/marshal"

SuperModel::Marshal.path = "dump_client.db"
SuperModel::Marshal.load

at_exit {
  SuperModel::Marshal.dump
}

unless $0 =~ /irb/
  EM.run {
    EM.connect("0.0.0.0", 10000, MyConnection)
  }
end