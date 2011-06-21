require 'rubygems'
require 'bundler'
Bundler.setup(:default, :development)
ENV['RACK_ENV'] = 'test'
require 'test/unit'
require 'rack/test'
require 'active_record'
require 'shoulda'
require 'shoulda/active_record'

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))
require 'communicator'
require 'factories'

# Connect to client test database
ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "db/test_client.sqlite3")
require 'lib/post'
require 'lib/comment'

# Connect to server database too so we can peek into what's happening over there
class TestServerDatabase < ActiveRecord::Base
  establish_connection(:adapter => 'sqlite3', :database => "db/test_server.sqlite3")  
end
require 'lib/test_server_database/post'
require 'lib/test_server_database/comment'
require 'lib/test_server_database/inbound_message'
require 'lib/test_server_database/outbound_message'

class Test::Unit::TestCase
  def setup
    # Reset communicator credentials every time
    Communicator.username = nil
    Communicator.password = nil
    Communicator::Client.base_uri nil
    
    # Purge the databases every time...
    Communicator::InboundMessage.delete_all
    Communicator::OutboundMessage.delete_all
    Communicator::Mapping.delete_all
    Post.delete_all
    Comment.delete_all
    
    TestServerDatabase::InboundMessage.delete_all
    TestServerDatabase::OutboundMessage.delete_all
    TestServerDatabase::Post.delete_all
    TestServerDatabase::Comment.delete_all
  end
  
  # Retrieves the test server port that is generated randomly (see Rakefile)
  # from the tempfile...
  def server_port
    File.read(File.join(File.dirname(__FILE__), '../tmp/server_port')).strip.chomp
  rescue => err
    err.message = "Failed to retrieve test server port. Are you sure test server is running? #{err.message}"
    raise err
  end
end
