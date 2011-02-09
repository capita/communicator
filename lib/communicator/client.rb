require 'httparty'
class Communicator::Client
  class ServerError < StandardError; end;
  class AuthError < StandardError; end;
  class InvalidStartingId < StandardError; end;

  include HTTParty
  default_timeout 10
  
  class << self
    attr_writer :username, :password
    # Return configured username for http auth basic or raise an error message if not configured
    def username
      @username || raise(Communicator::MissingCredentials.new("No Username specified for HTTP AUTH. Please configure using Communicator::Client.username='xyz'"))
    end

    # Return configured password for http auth basic or raise an error message if not configured    
    def password
      @password || raise(Communicator::MissingCredentials.new("No Password specified for HTTP AUTH. Please configure using Communicator::Client.password='xyz'"))
    end
    
    # Helper for basic auth in httparty-expected format for request options
    def credentials
      {:username => username, :password => password}
    end
    
    def pull
      request = get('/messages.json', :query => {:from_id => Communicator::InboundMessage.last_id+1}, :basic_auth => credentials)
      verify_response request.response
      Communicator::InboundMessage.create_from_json_collection!(JSON.parse(request.parsed_response))
      request
      
    # Customize error message on HTTP Timeout
    rescue Timeout::Error => err
      err.message << " - Failed to PULL from #{base_uri}"
      raise err
    end
  
    def push(from_id=nil)
      messages = Communicator::OutboundMessage.delivery_collection(from_id)
      request = post("/messages.json", :body => messages.map(&:payload).to_json, :basic_auth => credentials)
      verify_response request.response
      # Everything went fine? Mark the messages as delivered
      messages.each {|m| m.delivered! }
      request
    
    # Retry when server sent a from_id expectation
    rescue Communicator::Client::InvalidStartingId => err
      unless from_id
        push(request.response.body)
      else
        raise "Could not agree upon from_id with server!"
      end
      
    # Customize error message on HTTP Timeout
    rescue Timeout::Error => err
      err.message << " - Failed to PUSH to #{base_uri}"
      raise err
    end
    
    def verify_response(response)
      if response.kind_of?(Net::HTTPSuccess)
        return true
      elsif response.kind_of?(Net::HTTPUnauthorized) or response.kind_of?(Net::HTTPForbidden)
        raise Communicator::Client::AuthError.new("Failed to authenticate!")
      elsif response.kind_of?(Net::HTTPConflict)
        raise Communicator::Client::InvalidStartingId.new("Expected from_id to begin with #{response.body.strip.chomp}")
      elsif response.kind_of?(Net::HTTPServerError)
        raise Communicator::Client::ServerError.new("Request failed with #{response.class}")
      end
    end
  end

end
