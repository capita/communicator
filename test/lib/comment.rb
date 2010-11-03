# A simple class for publishing and receiving messages
class Comment < ActiveRecord::Base
  receives_from :comment, :except => [:title]
  after_save do |r|
    r.publish unless r.updated_from_message
  end
end