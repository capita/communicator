# Basic class for introspection of what is happening on the server side
class TestServerDatabase::InboundMessage < TestServerDatabase
  set_table_name "inbound_messages"
end