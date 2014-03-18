class AddFlights < ActiveRecord::Migration
  def change
    create_table :flights do |t|
      t.string :flight_radar_id
      t.string :registration_one
      t.string :registration_two
      t.string :aircraft_code
      t.string :aircraft_name
      t.string :departure_airport
      t.string :arrival_airport
      t.string :flight_no
      t.string :call_sign
      t.string :airline
      t.string :payload
      t.integer :scheduled_departure
      t.integer :scheduled_arrival
      t.integer :departure_time
      t.integer :arrival_time
      t.integer :eta

      t.timestamps
    end

    create_table :snapshots do |t|
      t.float :latitude
      t.float :longitude
      t.integer :track
      t.integer :altitude
      t.integer :speed
      t.string :squawk
      t.string :radar
      t.integer :vertical_speed
      t.integer :flight_id
      t.string :payload

      t.timestamps
    end

    create_table :airports do |t|
      t.string :name
      t.float :latitude
      t.float :longitude
      t.string :types
      t.string :size
      t.integer :status
      t.string :iso
      t.string :continent
      t.string :code

      t.timestamps
    end

    add_index :airports, :code
    add_index :flights, :flight_radar_id, :unique => true
  end
end
