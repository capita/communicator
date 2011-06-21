class AddIdentityColumnsToMessages < ActiveRecord::Migration
  def self.up
    add_column :outbound_messages, :origin, :string, :null => true, :length => 25
    add_column :outbound_messages, :original_id, :integer, :null => true

    add_column :inbound_messages, :origin, :string, :null => true, :length => 25
    add_column :inbound_messages, :original_id, :integer, :null => true
  end

  def self.down
    remove_column :outbound_messages, :origin
    remove_column :outbound_messages, :original_id
    remove_column :inbound_messages, :origin
    remove_column :inbound_messages, :original_id
  end
end

