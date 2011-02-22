require 'sinatra'

class Communicator::Server < Sinatra::Base
  # Configuration parameters
  class << self
    attr_writer :username, :password
    
    # Return configured username for http auth basic or raise an error message if not configured
    def username
      @username || raise("No Username specified for HTTP AUTH. Please configure using Communicator::Server.username='xyz'")
    end

    # Return configured password for http auth basic or raise an error message if not configured    
    def password
      @password || raise("No Password specified for HTTP AUTH. Please configure using Communicator::Server.password='xyz'")
    end
  end
  
  helpers do
    def protected!
      unless authorized?
        response['WWW-Authenticate'] = %(Basic realm="Testing HTTP Auth")
        throw(:halt, [401, "Not authorized\n"])
      end
    end
  
    def authorized?
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      @auth.provided? && @auth.basic? && @auth.credentials && @auth.credentials == [Communicator::Server.username, Communicator::Server.password]
    end
  end

  
  # PULL
  get '/messages.json' do
    protected!
    # Require from_id attribute
    return [409, "Specify from_id!"] unless params[:from_id]

    begin
      # from_id is irrelevant when no messages are present
      params[:from_id] = nil if Communicator::OutboundMessage.count == 0
      
      # Fetch the messages and build the json
      messages = Communicator::OutboundMessage.delivery_collection(params[:from_id])
      json = messages.map(&:payload).to_json
      # Flag the messages as delivered
      messages.each {|m| m.delivered! }
      
      # Collect the message payloads and render them as json
      [200, json]
      
    rescue => err
      Communicator::ExceptionHandler.publish_and_reraise err, "Status" => "Server failed to publish outbound messages!"
    end
  end
  
  # PUSH
  post '/messages.json' do
    protected!
    
    begin
      body = request.body.read.strip
      # Make sure a message body is given!
      return [409, "No data given"] if body.length < 2
      # Parse json
      json_messages = JSON.parse(body)
      
      # If no messages present, just return
      return [202, "No data given"] unless json_messages.length > 0
     
      # Make sure the first id does directly follow the last one present locally - but only if we already have ANY messages
      # On failure, render HTTPConflicht and expected from_id
      return [409, (Communicator::InboundMessage.last_id + 1).to_s] unless Communicator::InboundMessage.valid_next_id?(json_messages.first["id"])
      
      # Everything's fine? Let's store messages!
      Communicator::InboundMessage.create_from_json_collection!(json_messages)
      
      # Unlock from exceptions after successfull PUSH
      Communicator::ExceptionHandler.unlock!
      
      202 # ACCEPTED
      
    rescue => err
      Communicator::ExceptionHandler.publish_and_reraise err, "Status" => "Server failed to receive inbound messages!"
    end
  end
end

require 'pp'
