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
        assert new_post.new_record?, "Should be a new record"
        assert_equal Post, new_post.class
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

  context "Post.find_for_mapping(:origin => 'source', :original_id => 72)" do
    setup do
      @new_post = Post.find_for_mapping(:origin => 'source', :original_id => 72)
      @new_post.title = 'Foo'
      @new_post.body = 'Bar'
    end

    should("be a new record") { assert @new_post.new_record? }
    should("have class Post") { assert_equal Post, @new_post.class }
    should("have class Mapping") { assert_equal Communicator::Mapping, @new_post.mapping.class }

    context "after save" do
      setup do 
        @new_post.save!
      end

      should "have stored the mapping" do
        assert !@new_post.mapping.new_record?
      end

      should "have original_id 72 in mapping" do
        assert_equal 72, @new_post.mapping.original_id
      end

      should "have origin 'source' in mapping" do
        assert_equal 'source', @new_post.mapping.origin
      end

      should "find the new post with Post.find_for_mapping" do
        assert_equal @new_post, Post.find_for_mapping(:origin => 'source', :original_id => 72)
      end
    end
  end
end
