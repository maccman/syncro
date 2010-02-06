require File.join(File.dirname(__FILE__), *%w[.. lib syncro])
require "eventmachine"
require "supermodel"

class Test < SuperModel::Base
  include SuperModel::Persist::Model
  include SuperModel::Scriber::Model
  include Syncro::Model
end

class MyConnection < EM::Connection
  def post_init
    Syncro.connect("server", self)
  end
  
  def receive_data(data)
    puts "Received: #{data}"
    Syncro.receive_data("server", data)
  end
  
  def send_data(data)
    puts "Sending: #{data}"
    super(data)
  end
end

SuperModel::Persist.path = "dump.db"
SuperModel::Persist.load

at_exit {
  SuperModel::Persist.dump
}

unless $0 =~ /irb/
  EM.run {
    EM.connect("0.0.0.0", 10000, MyConnection)
  }
end