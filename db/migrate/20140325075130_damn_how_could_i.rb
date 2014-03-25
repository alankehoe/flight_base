class DamnHowCouldI < ActiveRecord::Migration
  def change
  	change_table :snapshots do |t|
      t.change :flight_id, :string
  	end
  end
end
