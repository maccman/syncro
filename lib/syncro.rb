gem "supermodel", ">= 0.1.3"
require "supermodel"

gem "activesupport"
require "active_support"
require "active_support/core_ext/class/attribute"
require "active_support/core_ext/object/blank"
require "active_support/core_ext/module/delegation"
require "active_support/core_ext/string/inflections"
require "active_support/json"

module Syncro
  class SyncroError < StandardError; end
  class InvokeError < SyncroError;
    attr_reader :code
    def initialize(code = 0)
      @code = code
    end
  end
  
  def klasses
    @klasses ||= []
  end
  module_function :klasses
end

$:.unshift(File.dirname(__FILE__))

require "syncro/app"
require "syncro/client"
require "syncro/base"
require "syncro/model"
require "syncro/protocol/message"
require "syncro/protocol/message_buffer"
require "syncro/response"
require "syncro/rpc"
require "syncro/session"
require "syncro/scriber"
require "syncro/scriber/base"
require "syncro/scriber/model"
require "syncro/scriber/observer"
require "syncro/scriber/scribe"
require "syncro/scriber/scribe_observer"