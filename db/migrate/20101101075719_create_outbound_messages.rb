class CreateOutboundMessages < ActiveRecord::Migration
  def self.up
    create_table :outbound_messages do |t|
      t.text     :body, :null => false
      t.datetime :delivered_at, :default => nil
      t.timestamps
    end
  end

  def self.down
    drop_table :outbound_messages
  end
end
