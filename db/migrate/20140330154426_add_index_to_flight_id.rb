class AddIndexToFlightId < ActiveRecord::Migration
  def change
    add_index :snapshots, :flight_id
  end
end
