# ActiveRecord hooks for Communicator
module Communicator::ActiveRecordIntegration
  module Hook
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
  end

  module ClassMethods
    def skipped_remote_attributes
      @skipped_remote_attributes ||= []
    end
    
    def skip_remote_attributes(*attr_names)
      attr_names.each do |attr_name|
        skipped_remote_attributes << attr_name.to_sym
      end
    end

    def find_for_mapping(conditions)
      mapping = Communicator::Mapping.find(:first, :conditions => {:origin => conditions[:origin], :original_id => conditions[:original_id]})
      if mapping
        mapping.local_record
      else
        record = new
        record.build_mapping(:origin => conditions[:origin], :original_id => conditions[:original_id])
        record
      end
    end
  end
  
  # Instance methods that are to be mixed in to receiver classes
  module InstanceMethods
    # Instance variable to store whether this instance has been updated from remote message
    attr_accessor :updated_from_message

    def self.included(base)
      base.class_eval do
        has_one :mapping, :class_name => "Communicator::Mapping", :as => :local_record
        after_create :add_local_mapping
      end
    end

    def add_local_mapping
      create_mapping(:origin => Communicator.name, :original_id => id) unless mapping
      true
    end

    # Publishes this instance as an OutboundMessage with json representation as body
    def publish
      msg = Communicator::OutboundMessage.create!(:body => {self.class.to_s.underscore => attributes.except(:id)}.to_json, :original_id => mapping.try(:original_id), :origin => mapping.try(:origin))
      Communicator.logger.info "Publishing updates for #{self.class} ##{id}"
      msg
    end
    
    # Processes the given message body by applying all contained attributes and their values
    # and saving. When the setter instance method is missing on the local record, skip that attribute.
    def process_message(input)
      Communicator.logger.info "Processing json message content on #{self.class} ##{id}"
      # When the input is still json, parse it. Otherwise we're assuming it's already a demarshalled hash
      input = JSON.parse(input) if input.kind_of?(String)
      input.each do |attr_name, value|
        # Exclude skipped attributes
        next if self.class.skipped_remote_attributes.include?(attr_name.to_sym) or !attributes.has_key?(attr_name)
        self.send("#{attr_name}=", value)
      end
      self.updated_from_message = true
      save!
      
    rescue => err
      Communicator.logger.warn "Failed to process message on #{self.class} ##{id}! Errors: #{self.errors.map{|k,v| "#{k}: #{v}"}.join(", ")}"
      if err.respond_to?(:context)
        err.context["Validation Errors"] = "Errors: #{self.errors.map{|k,v| "#{k}: #{v}"}.join(", ")}"
        err.context["JSON Input"] = input.inspect
      end
      raise err
    end
  end
end
