module Syncro
  class Response
    cattr_accessor :callbacks
    self.callbacks = {}
    
    def self.expect(client, message_id, prok = nil, &block)
     	self.callbacks[client] ||= {}
      self.callbacks[client][message_id] = (prok||block)
    end
    
    def self.call(client, message_id, *args)
    	callback = self.callbacks[client].delete(message_id)
			callback && callback.call(*args)
    end
  end
end
