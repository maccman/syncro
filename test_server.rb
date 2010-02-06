require "lib/syncro"
require "eventmachine"

class Test < SuperModel::Base
  include SuperModel::Persist::Model
  include SuperModel::Scriber::Model
  include Syncro::Model
end

class MyConnection < EM::Connection
  def post_init
    Syncro.connect("client-guid", self)
  end
  
  def receive_data(data)
    puts "Recieve: #{data}"
    Syncro.receive("client-guid", data)
  end
end

SuperModel::Persist.path = "dump.db"
SuperModel::Persist.load

at_exit {
  SuperModel::Persist.dump
}

unless $0 =~ /irb/
  EM.run {
    EM.start_server("0.0.0.0", 10000, MyConnection)
  }
end