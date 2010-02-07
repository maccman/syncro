module Syncro
  module Scriber
    class Scribe < SuperModel::Base
      class << self
        def since(client, id)
          record = find(id)
          index  = records.index(record)
          items  = records.slice(index + 1, -1)
          items  = items.select {|item| 
            item.clients.blank? || item.clients.include?(client) 
          }
          items.dup
        rescue SuperModel::UnknownRecord
          []
        end
      
        def all(client)
          items = records.select {|item| 
            item.clients.blank? || item.clients.include?(client) 
          }
          items.dup
        end
      end
    
      attributes :klass, :type, :data, :clients
      validates_presence_of :klass, :type
  
      def play
        klass.constantize.scribe_play(self)
      end
    
      def klass=(klass)
        write_attribute(:klass, klass.to_s)
      end
      
      def clients=(clients)
        return if clients.blank?
        write_attribute(:clients, clients.map(&:to_s))
      end
    end
  end
end