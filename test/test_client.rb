require 'helper'

#
# Unit tests for client and it's interaction with the real server running in background
# on port 20359. For introspection purposes, a simple second database connection
# has been established as TestServerDatabase
#
class TestClient < Test::Unit::TestCase
  context "Without auth credentials configured" do
    context "PUSH" do
      should "raise an exception" do
        assert_raise Communicator::MissingCredentials do 
          Communicator::Client.push
        end
      end
    end
    
    context "PULL" do
      should "raise an exception" do
        assert_raise Communicator::MissingCredentials do 
          Communicator::Client.pull
        end
      end
    end
  end
  
  context "with server configured" do
    setup do
      Communicator::Client.username = 'testuser'
      Communicator::Client.password = 'pwd'
      Communicator::Client.base_uri 'localhost:20359'
    end
    
    context "PUSH" do
      setup { Communicator::Client.push }
      
      should "not have any inbound messages in server" do
        assert_equal 0, TestServerDatabase::InboundMessage.count
      end
    end
    
    context "PULL" do
      setup { Communicator::Client.pull }
      
      should "not have any inbound messages locally" do
        assert_equal 0, Communicator::InboundMessage.count
      end
    end
    
    context "after creating a local Post" do
      setup do
        @post = Post.create!(:title => 'foo', :body => 'local post')
      end
      
      should "have created an outbound message locally" do
        assert_equal 'local post', Communicator::OutboundMessage.first.message_content["post"]["body"]
        assert_nil Communicator::OutboundMessage.first.delivered_at
      end
      
      context "after PUSH" do
        setup { Communicator::Client.push }
        
        should "have flagged the outbound message as delivered" do
          assert_equal 0, Communicator::OutboundMessage.undelivered.count
        end
        
        should "have created the corresponding inbound message at remote" do
          assert_equal 1, TestServerDatabase::InboundMessage.count
          assert msg = TestServerDatabase::InboundMessage.first
          assert_equal 'local post', JSON.parse(msg.body)["post"]["body"]
          assert_equal 'foo', JSON.parse(msg.body)["post"]["title"]
          assert msg.processed_at > 3.seconds.ago
        end
        
        should "have created the corresponding Post at remote" do
          assert_equal 1, TestServerDatabase::Post.count
          assert post = TestServerDatabase::Post.first
          assert_equal 'local post', post.body
          assert_equal 'foo', post.title
        end
        
        should "not have created outbound message at remote" do
          assert_equal 0, TestServerDatabase::OutboundMessage.count
        end
        
        context "when i try to PUSH the same message again" do
          setup do
            @post.title = 'changed'
            Communicator::OutboundMessage.first.update_attribute(:body, @post.to_json)
            Communicator::OutboundMessage.first.update_attribute(:delivered_at, nil)
            Communicator::Client.push
          end
          
          should "not have updated the remote message" do
            assert_equal 1, TestServerDatabase::InboundMessage.count
            assert_equal 'foo', JSON.parse(TestServerDatabase::InboundMessage.first.body)["post"]["title"]
          end
        end
        
        context "when an update message is created at remote" do
          setup do
            @remote_msg = TestServerDatabase::OutboundMessage.create!(:body => {:post => {:id => @post.id, :title => 'new title', :body => 'remote body'}}.to_json)
          end
          
          context "a PULL" do
            setup do
              Communicator::Client.pull
            end
            
            should "result in the local post getting updated" do
              @post.reload
              assert_equal 'new title', @post.title
              assert_equal 'remote body', @post.body
            end
            
            should "have created the corresponding inbound message" do
              assert_equal 1, Communicator::InboundMessage.count
            end
          end
        end
      end
    end
    
    context "when an update message is created at remote" do
      setup do
        @remote_msg = TestServerDatabase::OutboundMessage.create!(:body => {:post => {:id => 25, :title => 'new title', :body => 'remote body'}}.to_json)
      end
      
      context "a PULL" do
        setup do
          Communicator::Client.pull
        end
        
        should "result in a local post getting created" do
          post = Post.find(25)
          assert_equal 'new title', post.title
          assert_equal 'remote body', post.body
        end
        
        should "have created the corresponding inbound message" do
          assert_equal 1, Communicator::InboundMessage.count
        end
      end
    end
  end
end