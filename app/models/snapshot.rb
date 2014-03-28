class Snapshot < ActiveRecord::Base

  belongs_to :flight, :foreign_key => :flight_id, :primary_key => :flight_radar_id, :class_name => 'Flight'

  class << self
    def create_with_data(flight_id, array)
      snapshot = Snapshot.new
      snapshot.latitude = array[1]
      snapshot.longitude = array[2]
      snapshot.track = array[3]
      snapshot.altitude = array[4]
      snapshot.speed = array[5]
      snapshot.squawk = array[6]
      snapshot.radar = array[7]
      snapshot.vertical_speed = array[15]
      snapshot.flight_id = flight_id
      snapshot.payload = array.to_s
      snapshot
    end
  end

end