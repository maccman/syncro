module Syncro
  class Response
    cattr_accessor :callbacks
    self.callbacks = {}
    
    def self.expect(client, prok = nil, &block)
     	self.callbacks[client] ||= []
      self.callbacks[client] << (prok||block)
    end
    
    def self.call(client, args)
    	callback = self.callbacks[client].shift
			callback && callback.call(args)
    end
  end
end
