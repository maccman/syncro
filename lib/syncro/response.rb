module Syncro
  class Response
    cattr_accessor :callbacks
    self.callbacks = {}
    
    def self.expect(namespace, message_id, prok = nil, &block)
     	self.callbacks[namespace] ||= {}
      self.callbacks[namespace][message_id] = (prok||block)
    end
    
    def self.call(namespace, message_id, *args)
    	callback = self.callbacks[namespace].delete(message_id)
			callback && callback.call(*args)
    end
  end
end
