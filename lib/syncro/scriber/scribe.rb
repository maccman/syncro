module Syncro
  module Scriber
    class Scribe < SuperModel::Base
      include SuperModel::RandomID
      
      # In Rails 3, this defaults to true.
      # We don't want it, otherwise the protocols invalid.
      self.include_root_in_json = false
      
      class << self
        def since(client, scribe_id)
          record = find(scribe_id)
          values = records.values
          index  = values.index(record)
          items  = values.slice((index + 1)..-1)
          items  = items.select {|item| 
            item.to_all || item.clients.include?(client)
          }
          items.deep_dup
        rescue SuperModel::UnknownRecord
          []
        end
      
        def for_client(client)
          items = records.values.select {|item| 
            item.clients.include?(client) 
          }
          items.deep_dup
        end
      end
      
      belongs_to :from_session, :class_name => "Syncro::Session"
      belongs_to :from_client,  :class_name => "Syncro::Client"
    
      attributes :klass, :type, :data, :client_ids, :to_all
            
      validates_presence_of :klass, :type
      validate :valid_recipient
  
      def play
        klass.constantize.scribe_play(self)
      end
    
      def klass=(klass)
        write_attribute(:klass, klass.to_s)
      end
      
      def clients
        if to_all
          Client.all
        else
          (client_ids || []).map {|id| Client.find(id) }
        end
      end
      
      def clients=(clients)
        self.client_ids = (clients && clients.map(&:id))
      end
      
      def client_uids=(uids)
        if uids == :all
          self.to_all = true
        else
          self.clients = (uids && uids.map {|uid| Client.for(uid) })
        end
      end
      
      def from_scribe=(scribe)
        return unless scribe
        self.from_client  = scribe.from_client
        self.from_session = scribe.from_session
      end
      
      def to_sessions
        sessions = clients.map(&:sessions).flatten
        # Don't want to send any data from sessions that
        # originally sent the same data to us.
        sessions.delete(from_session)
        sessions
      end
            
      def as_json(options = nil)
        options ||= {}
        options[:except] ||= []
        options[:except] << :client_ids
        options[:except] << :from_session_id
        options[:except] << :from_client_id
        options[:except] << :to_all
        serializable_hash(options)
      end
      
      protected
      
        def valid_recipient
          return if to_all || clients.any?
          errors.add(:clients, "is not valid")
        end
    end
  end
end