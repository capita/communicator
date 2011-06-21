require 'helper'

class TestMapping < Test::Unit::TestCase
  context "A new mapping" do
    subject { Communicator::Mapping.new }
    should_validate_presence_of :origin, :original_id, :local_record_type, :local_record_id
    should_belong_to(:local_record)
  end

  context "With a Post" do
    setup do
      @post = Post.create!(:title => 'foo', :body => 'bar')
    end

    context ", a mapping for this Post" do
      setup do
        @mapping = Communicator::Mapping.create!(:origin => 'remote', :original_id => 72, :local_record => @post)
      end

      should "return the post as local_record" do
        assert_equal @post, @mapping.reload.local_record
      end

      should "return the mapping for the post" do
        assert_equal @mapping, @post.reload.mapping
      end

      should "return the post for Post.find_for_mapping(:origin => 'remote', :original_id => 72)" do
        assert_equal @post, Post.find_for_mapping(:origin => 'remote', :original_id => 72)
      end

      should "return a new Post for Post.find_for_mapping(:origin => 'remote', :original_id => 76)" do
        assert new_post = Post.find_for_mapping(:origin => 'remote', :original_id => 76)
        assert new_post.new_record?, "Should be a new record"
        assert_equal Post, new_post.class
      end

      should "return a new Post for Post.find_for_mapping(:origin => 'source', :original_id => 72)" do
        assert new_post = Post.find_for_mapping(:origin => 'source', :original_id => 72)
        new_post.title = 'Foo'
        new_post.body = 'Bar'
        
        assert new_post.new_record?, "Should be a new record"
        assert_equal Post, new_post.class
        assert_equal Communicator::Mapping, new_post.mapping.class

        assert new_post.save
        new_post.reload
        assert_equal 72, new_post.mapping.original_id
        assert_equal 'source', new_post.mapping.origin
      end

      should "raise a db error when trying to create a different mapping for the same post" do
        assert_raise ActiveRecord::StatementInvalid do
          Communicator::Mapping.create!(:origin => 'remote', :original_id => 73, :local_record => @post)
        end
      end

      should "raise a db error when trying to create another mapping for the remote and another record" do
        assert_raise ActiveRecord::StatementInvalid do
          Communicator::Mapping.create!(:origin => 'remote', :original_id => 72, :local_record => Post.create!(:title => 'foo2', :body => 'bar2'))
        end
      end
    end
  end
end
