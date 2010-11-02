class CreateInboundMessages < ActiveRecord::Migration
  def self.up
    create_table :inbound_messages do |t|
      t.text     :body, :null => false
      t.datetime :processed_at, :default => nil
      t.timestamps
    end
  end

  def self.down
    drop_table :inbound_messages
  end
end
