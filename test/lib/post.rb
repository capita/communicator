# A simple class for publishing and receiving messages
class Post < ActiveRecord::Base
  receives_from :post
  after_save do |p|
    p.publish unless p.updated_from_message
  end
end