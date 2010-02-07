require File.join(File.dirname(__FILE__), *%w[.. lib syncro])
require "eventmachine"
require "supermodel"

class Test < SuperModel::Base
  include SuperModel::Marshal::Model
  include Syncro::Model
  
  def scribe_clients
    [:client_uuid1, :client_uuid2]
  end
end

class MyConnection < EM::Connection
  def post_init
    @client = Syncro::Client.for(:client_uuid1)
    @client.connect(self)
    @client.sync
  end
  
  def receive_data(data)
    puts "Received: #{data}"
    @client.receive_data(data)
  end
  
  def send_data(data)
    puts "Sending: #{data}"
    super(data)
  end
  
  def unbind
    @client.disconnect
  end
end

require "syncro/marshal"

SuperModel::Marshal.path = "dump_server.db"
SuperModel::Marshal.load

at_exit {
  SuperModel::Marshal.dump
}

unless $0 =~ /irb/
  EM.run {
    EM.start_server("0.0.0.0", 10000, MyConnection)
  }
end