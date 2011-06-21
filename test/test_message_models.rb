require 'helper'

class TestMessageModels < Test::Unit::TestCase
  context "A new inbound message" do
    subject { Communicator::InboundMessage.new }
    should_validate_presence_of :body
  end
  
  context "A new outbound message" do
    subject { Communicator::OutboundMessage.new }
    should_validate_presence_of :body
  end
  
  context "With a couple inbound messages existing" do
    setup { 5.times { Factory.create(:inbound_message) } }
    
    should "return an appropriate last_id" do
      assert_equal Communicator::InboundMessage.last_id, Communicator::InboundMessage.all.map(&:id).sort.last
    end
  end
  
  context "An inbound message for a post that does not exist locally yet" do
    setup do
      @message = Factory.create(:inbound_message)
      @post = ::Post.find_by_title!(JSON.parse(@message.body)["post"]["title"])
    end
    
    should "have all attributes of the post matching those in the json body (except for id :)" do
      JSON.parse(@message.body)["post"].each do |attr_name, value|
        assert_equal @post.send(attr_name), value
      end
    end
    
    context "after another Inbound Message for the same Post" do
      setup do
        @update_message = Factory.create(:inbound_message, 
          :origin => @message.origin,
          :original_id => @message.original_id,
          :body => {
            :post => { :id => @post.id, 
                       :title => 'new title', 
                       :body => 'new malarkey'} }.to_json)
        @post.reload
      end
      
      should "have updated the posts title and body" do
        assert_equal @post.title, 'new title'
        assert_equal @post.body,  'new malarkey'
      end
      
      should "not have created any Outbound messages" do
        assert_equal 0, Communicator::OutboundMessage.count
      end
      
      context "after an update to the post" do
        setup do
          @post.title = 'changed locally'
          @post.save!
        end
        
        should "Have created an outbound message" do
          assert_equal 1, Communicator::OutboundMessage.count
        end
        
        should "have an outbound message with correct title" do
          assert_equal 'changed locally', JSON.parse(Communicator::OutboundMessage.first.body)["post"]["title"]
        end
      end
    end
  end
end
