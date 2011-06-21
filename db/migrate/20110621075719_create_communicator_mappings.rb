class CreateCommunicatorMappings < ActiveRecord::Migration
  def self.up
    create_table :communicator_mappings do |t|
      t.string  :origin, :length => 25, :null => false
      t.integer :original_id, :null => false
      t.string  :local_record_type, :null => false
      t.integer :local_record_id, :null => false
      t.timestamps
    end
  end

  def self.down
    drop_table :communicator_mappings
  end
end

