require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'json'
require 'active_record'

module Communicator
  # Error to be raised when no receiver can be found for a message that is to be processed
  class ReceiverUnknown < StandardError; end;
  
  # Error to be raised when no credentials were given
  class MissingCredentials < StandardError; end;
  
  class << self
    # Hash containing all receivers
    def receivers
      @recevers ||= {}.with_indifferent_access
    end
    
    # Register a given class as a receiver from source (underscored name). Will then
    # mix in the instance methods from Communicator::ActiveRecord::InstanceMethods so
    # message processing and publishing functionality is included
    def register_receiver(target, source, options={})
      receivers[source] = target
      target.send(:include, Communicator::ActiveRecordIntegration::InstanceMethods)
      
      target.skip_remote_attributes(*options[:except]) if options[:except]
      
      target
    end
    
    # Tries to find the receiver for given source, raising Communicator::ReceiverUnknown
    # on failure
    def receiver_for(source)
      return receivers[source] if receivers[source]
      
      # If not found in the first place, maybe the class just isn't loaded yet and
      # thus hasn't registered - let's require all models and try again
      if defined?(Rails)
        Dir[File.join(Rails.root, 'app/models/**/*.rb')].each {|model| require model}
        return receivers[source] if receivers[source]
      end
      
      # When everything else fails, just throw an exception...
      raise Communicator::ReceiverUnknown.new("No receiver registered for '#{source}'")
    end
  end
end

require 'communicator/server'
require 'communicator/client'
require 'communicator/active_record_integration'
require 'communicator/outbound_message'
require 'communicator/inbound_message'