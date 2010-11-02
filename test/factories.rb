require 'factory_girl'
Factory.sequence(:inbound_record_id) {|i| i}
Factory.sequence(:outbound_record_id) {|i| i}

Factory.define(:inbound_message, :class => Communicator::InboundMessage) do |f|
  f.body { {:post => {:id => Factory.next(:inbound_record_id), :title => 'foo', :body => 'bar'}}.to_json }
end

Factory.define(:outbound_message, :class => Communicator::OutboundMessage) do |f|
  f.body { {:post => {:id => Factory.next(:outbound_record_id), :title => 'foo', :body => 'bar'}}.to_json }
end
