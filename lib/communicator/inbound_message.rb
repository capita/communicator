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
    Communicator.logger.info "Created inbound message from json, local id is #{inbound_msg.id}"
    inbound_msg
    
  rescue => err
    # Add context to exception when using capita/exception_notification fork
    if err.respond_to?(:context)
      err.context["Validation Errors"] = "Errors: #{inbound_msg.errors.map{|k,v| "#{k}: #{v}"}.join(", ")}"
      err.context["Inbound Message"] = inbound_msg.attributes.inspect
      err.context["JSON Message"] = json_message.inspect
    end
    
    raise err
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
    @message_content ||= JSON.parse(body).with_indifferent_access
  end
  
  # Figure out who is the receiver of this message and process the message
  def process!
    if processed_at.present? # Do not process if already processed!
      Communicator.logger.info "InboundMessage #{id} has already been processed, not processing again!"
      return false
    end
    source, content = message_content.first
    
    # We have to distinguish here between inbound messages that have an id and those that
    # don't since some databases (at least Postgres) will raise an error when the ID is set to nil on
    # the ActiveRecord instance because AR includes the id column and it's "NULL" value in the
    # INSERT statement
    if content["id"]
      Communicator.receiver_for(source).find_or_initialize_by_id(content["id"]).process_message(content)
    else
      Communicator.receiver_for(source).new.process_message(content)
    end
    self.processed_at = Time.now
    self.save!
    Communicator.logger.info "Processed inbound message ##{id} successfully"
    
  rescue => err
    Communicator.logger.warn "Failed to store inbound message ##{id}! Errors: #{self.errors.map{|k,v| "#{k}: #{v}"}.join(", ")}"

    # Add context to exception when using capita/exception_notification fork
    if err.respond_to?(:context)
      err.context["Validation Errors"] = "Errors: #{self.errors.map{|k,v| "#{k}: #{v}"}.join(", ")}"
      err.context["Inbound Message"] = self.attributes.inspect
      err.context["JSON Content"] = self.message_content.inspect
    end
    
    raise err
  end
end
