require 'bundler'
Bundler.setup(:default, :development)

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$LOAD_PATH.unshift(File.dirname(__FILE__))

require 'active_record'
require 'communicator'

ActiveRecord::Base.establish_connection(:adapter => 'sqlite3', :database => "db/test_server.sqlite3")  
require 'lib/post'
require 'lib/comment'

Communicator::Server.username = 'testuser'
Communicator::Server.password = 'pwd'

run Communicator::Server