require 'rubygems'
require 'bundler'
Bundler.setup(:default)
require 'json'

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
    def register_receiver(target, source)
      receivers[source] = target
      target.send(:include, Communicator::ActiveRecordIntegration::InstanceMethods)
    end
    
    # Tries to find the receiver for given source, raising Communicator::ReceiverUnknown
    # on failure
    def receiver_for(source)
      return receivers[source] if receivers[source]
      raise Communicator::ReceiverUnknown.new("No receiver registered for '#{source}'")
    end
  end
end

require 'communicator/server'
require 'communicator/client'
require 'communicator/active_record_integration'
require 'communicator/outbound_message'
require 'communicator/inbound_message'