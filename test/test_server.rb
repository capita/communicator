require 'helper'
require 'base64'

# Unit tests for the server component using rack test in isolation
# Please note that this is using the CLIENT database, since we are testing locally
# as opposed to the tests of client/server interaction, which use the Client and Server
# DB
#
class TestServer < Test::Unit::TestCase
  include Rack::Test::Methods
  
  def app
    Communicator.username = 'someguy'
    Communicator.password = 'password'
    Communicator::Server
  end

  context "Unauthorized" do
    context "GET /messages.json" do
      setup { get '/messages.json' }
      should("return forbidden status") { assert_equal 401, last_response.status}
    end
    
    context "POST /messages.json" do
      setup { post '/messages.json' } 
      should("return forbidden status") { assert_equal 401, last_response.status}
    end
  end
  
  context "Authorized" do
    context "GET /messages.json" do
      context "without from_id" do
        setup { get '/messages.json', {}, auth_header('someguy', 'password') }
        should("return rejected status") { assert_equal 409, last_response.status}
      end
      
      context "with from_id" do
        setup { get '/messages.json', {:from_id => 1}, auth_header('someguy', 'password') }
        should("return success status") { assert_equal 200, last_response.status }
        should("return empty json array") { assert_equal "[]", last_response.body }
      end
      
      context "with 5 existing OutboundMessages starting at ID 1" do
        setup do 
          (1..5).each do |id| 
            msg = Factory.build(:outbound_message)
            msg.id = id
            msg.save!
          end
        end
        
        should "have 5 items in undelivered named_scope" do
          assert_equal 5, Communicator::OutboundMessage.undelivered.count
        end
        
        context "and proper from_id" do
          setup do
            get '/messages.json', {:from_id => 1}, auth_header('someguy', 'password')
            @json = JSON.parse(last_response.body)
          end

          should "have rendered successfully" do
            assert_equal 200, last_response.status
          end

          should "have returned 5 messages" do
            assert_equal 5, @json.length
          end

          should "have proper representations of all messages" do
            @json.each do |json|
              message = Communicator::OutboundMessage.find(json["id"])
              assert_equal message.body, json["body"]
            end
          end

          should "have flagged all outbound messages as delivered" do
            assert_equal 5, Communicator::OutboundMessage.delivered.count
          end

          should "have no outbound in undelivered named_scope" do
            assert_equal 0, Communicator::OutboundMessage.undelivered.count
          end

          context "another GET with updated from_id" do
            setup do
              get '/messages.json', {:from_id => Communicator::OutboundMessage.first(:order => 'id DESC').id+1}, auth_header('someguy', 'password')
            end

            should "have rendered empty json array" do
              assert_equal "[]", last_response.body
            end
          end

          context "and a from_id that is too low" do
            setup do
              # Here we have collected all pending messages, so we should be at id 5
              get '/messages.json', {:from_id => 3}, auth_header('someguy', 'password')
              @json = JSON.parse(last_response.body)
            end

            should "have rendered successfully" do
              assert_equal 200, last_response.status
            end

            should "have returned 3 messages" do
              assert_equal 3, @json.length
            end

            should "have proper representations of all messages" do
              @json.each do |json|
                message = Communicator::OutboundMessage.find(json["id"])
                assert_equal message.body, json["body"]
              end
            end

            should "still have flagged all outbound messages as delivered" do
              assert_equal 5, Communicator::OutboundMessage.delivered.count
            end

            should "still have no outbound in undelivered named_scope" do
              assert_equal 0, Communicator::OutboundMessage.undelivered.count
            end
          end
        end

        context "and a from_id that is too high" do
          setup do
            # Here we have collected no messages yet, so we should be at id 1
            get '/messages.json', {:from_id => 3}, auth_header('someguy', 'password')
            @json = JSON.parse(last_response.body)
          end

          should "have rendered successfully" do
            assert_equal 200, last_response.status
          end

          should "have returned 3 messages" do
            assert_equal 3, @json.length
          end

          should "have proper representations of all messages" do
            @json.each do |json|
              message = Communicator::OutboundMessage.find(json["id"])
              assert_equal message.body, json["body"]
            end
          end

          should "have flagged 3 outbound messages as delivered" do
            assert_equal 3, Communicator::OutboundMessage.delivered.count
          end

          should "have 2 outbound in undelivered named_scope" do
            assert_equal 2, Communicator::OutboundMessage.undelivered.count
          end
        end
      end
    end
    
    context "POST /messages.json" do
      context "without body" do
        setup { post '/messages.json', {}, auth_header('someguy', 'password') } 
        should("return rejected status") { assert_equal 409, last_response.status}
      end
      
      context "with empty array in body" do
        setup { post '/messages.json', "[]", auth_header('someguy', 'password') } 
        should("return accepted status") { assert_equal 202, last_response.status}
      end
      
      context "with 1 post in body" do
        setup do
          assert Communicator::InboundMessage.count == 0, "Should have no inbound"
          post '/messages.json', [{:original_id => 1, :origin => 'remote', :id => 1, :body => {:post => {:id => 1, :title => 'foo', :body => 'bar'}}.to_json}].to_json, auth_header('someguy', 'password')
        end
        should("return accepted status") { assert_equal 202, last_response.status }
        should "have created the inbound message" do
          assert_equal 1, Communicator::InboundMessage.count
        end
        should "have created the corresponding post" do
          assert post = Post.find_by_title('foo')
          assert_equal 'foo', post.title
          assert_equal 'bar', post.body
        end
      end
    end
  end
  
  private
  
  def auth_header(username, password)
    {'HTTP_AUTHORIZATION' => encode_credentials(username, password)}
  end

  def encode_credentials(username, password)
    "Basic " + Base64.encode64("#{username}:#{password}")
  end

end