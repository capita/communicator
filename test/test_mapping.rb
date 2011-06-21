require 'helper'

class TestMapping < Test::Unit::TestCase
  context "A new mapping" do
    subject { Communicator::Mapping.new }
    should_validate_presence_of :origin, :original_id, :local_record_type, :local_record_id
    should_belong_to(:local_record)
  end
end
