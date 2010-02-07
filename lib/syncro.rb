gem "supermodel"
require "supermodel"

module Syncro
  class SyncroError < StandardError; end
  
  def klasses
    @klasses ||= []
  end
  module_function :klasses
end

$:.unshift(File.dirname(__FILE__))

require "syncro/app"
require "syncro/client"
require "syncro/model"
require "syncro/protocol/message"
require "syncro/protocol/message_buffer"
require "syncro/response"
require "syncro/scriber"
require "syncro/scriber/model"
require "syncro/scriber/observer"
require "syncro/scriber/scribe"