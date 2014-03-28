class AddColumnToSnapshots < ActiveRecord::Migration
  def change
    add_column :snapshots, :dodgy, :boolean
  end
end
