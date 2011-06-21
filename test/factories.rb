require 'factory_girl'
Factory.sequence(:inbound_record_id) {|i| i}
Factory.sequence(:outbound_record_id) {|i| i}

Factory.define(:inbound_message, :class => Communicator::InboundMessage) do |f|
  f.origin 'remote'
  f.original_id { Factory.next(:inbound_record_id) }
  f.body {|m| {:post => {:title => 'foo', :body => 'bar'}}.to_json }
end

Factory.define(:outbound_message, :class => Communicator::OutboundMessage) do |f|
  f.origin { Communicator.name }
  f.original_id { Factory.next(:outbound_record_id) }
  f.body {|m| {:post => {:title => 'foo', :body => 'bar'}}.to_json }
end
