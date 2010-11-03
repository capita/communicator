# ActiveRecord hooks for Communicator
module Communicator::ActiveRecordIntegration
  module ClassMethods
    # Class method to register as a communicator receiver
    #
    # Usage (assuming you expect messages from "post"):
    #  class Post < ActiveRecord::Base
    #    receives_from :post
    #  end
    #
    def receives_from(source, options={})
      Communicator.register_receiver(self, source, options)
    end
    
    def skipped_remote_attributes
      @skipped_remote_attributes ||= []
    end
    
    def skip_remote_attributes(*attr_names)
      attr_names.each do |attr_name|
        skipped_remote_attributes << attr_name.to_sym
      end
    end
  end
  
  # Instance methods that are to be mixed in to receiver classes
  module InstanceMethods
    # Instance variable to store whether this instance has been updated from remote message
    attr_accessor :updated_from_message
    
    # Publishes this instance as an OutboundMessage with json representation as body
    def publish
      Communicator::OutboundMessage.create!(:body => {self.class.to_s.underscore => attributes}.to_json)
    end
    
    # Processes the given message body by applying all contained attributes and their values
    # and saving. When the setter instance method is missing on the local record, skip that attribute.
    def process_message(input)
      # When the input is still json, parse it. Otherwise we're assuming it's already a demarshalled hash
      input = JSON.parse(input) if input.kind_of?(String)
      input.each do |attr_name, value|
        # Exclude skipped attributes
        next if self.class.skipped_remote_attributes.include?(attr_name.to_sym) or !attributes.has_key?(attr_name)
        self.send("#{attr_name}=", value)
      end
      self.updated_from_message = true
      save!
    end
  end
end

# Include class methods into active record base
ActiveRecord::Base.send :extend, Communicator::ActiveRecordIntegration::ClassMethods

