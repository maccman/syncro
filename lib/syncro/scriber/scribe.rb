module Syncro
  module Scriber
    class Scribe < SuperModel::Base
      include SuperModel::RandomID
      
      class << self
        def since(client, id)
          record = find(id)
          index  = records.index(record)
          items  = records.slice((index + 1)..-1)
          return [] unless items
          items  = items.select {|item| 
            item.clients.blank? || item.clients.include?(client.to_s) 
          }
          items  = items.reject {|item|
            item.from_client == client
          }
          items.dup
        rescue SuperModel::UnknownRecord
          []
        end
      
        def for_client(client)
          items = records.select {|item| 
            item.clients.blank? || item.clients.include?(client.to_s) 
          }
          items  = items.reject {|item|
            item.from_client == client.to_s
          }
          items.dup
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