class Communicator::InboundMessage < ActiveRecord::Base
  set_table_name 'inbound_messages'
  
  validates_presence_of :body
  
  named_scope :unpublished, :conditions => {:processed_at => nil}
  default_scope :order => "id ASC"

  # Process messages that have been stored locally successfully
  after_create do |r|
    r.process!
  end
  
  # Creates an inbound message from a remote json hash
  def self.create_from_json!(json_message)
    inbound_msg = Communicator::InboundMessage.new(:body => json_message["body"])
    inbound_msg.id = json_message["id"]
    inbound_msg.save!
    inbound_msg
  end
  
  # Expects an already demarshalled collection array containing remote message data, which
  # will then all be processed indivdually using create_from_json!
  def self.create_from_json_collection!(json_messages)
    json_messages.map {|json_message| create_from_json!(json_message) }
  end
  
  # Find the last ID present locally
  def self.last_id
    count > 0 ? find(:first, :order => 'id DESC').id : 0
  end
  
  # Checks whether the given id is properly in line with the local last id
  # The check will only be actually performed when there are any locally stored inbound messages
  def self.valid_next_id?(from_id)
    Communicator::InboundMessage.count == 0 or from_id.to_i == Communicator::InboundMessage.last_id + 1
  end
  
  def message_content
    JSON.parse(body).with_indifferent_access
  end
  
  # Figure out who is the receiver of this message and process the message
  def process!
    return if processed_at.present? # Do not process if already processed!
    source, content = message_content.first
    Communicator.receiver_for(source).find_or_initialize_by_id(content["id"]).process_message(content)
    self.processed_at = Time.now
    self.save!
  end
end