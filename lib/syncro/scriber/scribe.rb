module Syncro
  module Scriber
    class Scribe < SuperModel::Base
      include SuperModel::RandomID
      
      # In Rails 3, this defaults to true.
      # We don't want it, otherwise the protocols invalid.
      self.include_root_in_json = false
      
      class << self
        def since(client, id)
          record = find(id)
          values = records.values
          index  = values.index(record)
          items  = values.slice((index + 1)..-1)
          return [] unless items
          items  = items.select {|item| 
            item.clients.blank? || item.clients.include?(client.to_s) 
          }
          items  = items.reject {|item|
            item.from_client == client.to_s
          }
          items.deep_dup
        rescue SuperModel::UnknownRecord
          []
        end
      
        def for_client(client)
          items = records.values.select {|item| 
            item.clients.blank? || item.clients.include?(client.to_s) 
          }
          items = items.reject {|item|
            item.from_client == client.to_s
          }
          items.deep_dup
        end
      end
    
      attributes :klass, :type, :data, :clients, :from_client
      validates_presence_of :klass, :type
  
      def play
        klass.constantize.scribe_play(self)
      end
    
      def klass=(klass)
        write_attribute(:klass, klass.to_s)
      end
      
      def to_json(options = {})
        options[:except] ||= []
        options[:except] << :clients
        options[:except] << :from_client
        super(options)
      end      
    end
  end
end