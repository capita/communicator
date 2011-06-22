class Communicator::OutboundMessage < ActiveRecord::Base
  set_table_name "outbound_messages"
  validates_presence_of :body
  
  named_scope :undelivered, :conditions => {:delivered_at => nil}
  named_scope :delivered, :conditions => "delivered_at IS NOT NULL"
  default_scope :order => "id ASC"
  
  # Returns an array of all undelivered messages. If the optional id is given
  # will instead start from that id, not taking care whether the messages have
  # already been marked as delivered.
  def self.delivery_collection(from_id=nil)
    (from_id ? all(:conditions => ["id >= ?", from_id]) : undelivered)
  end
  
  # Stripped down content hash for json delivery
  def payload
    {:id => id, :body => body, :origin => origin, :original_id => original_id}
  end
  
  # Will return the JSON-parsed content of this message's body
  def message_content
    JSON.parse(body).with_indifferent_access
  end
  
  # Set the delivered_at flag to NOW and save!
  def delivered!
    self.delivered_at = Time.now
    self.save!
  end
end