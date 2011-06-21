class Communicator::Mapping < ActiveRecord::Base
  set_table_name "communicator_mappings"

  validates_presence_of :origin, :original_id, :local_record_type, :local_record_id

  belongs_to :local_record, :polymorphic => true
end