# Basic class for introspection of what is happening on the server side
class TestServerDatabase::OutboundMessage < TestServerDatabase
  set_table_name "outbound_messages"
end