class Flight < ActiveRecord::Base

  has_many :snapshots, :class_name => 'Snapshot', :foreign_key => :flight_id, :primary_key => :flight_radar_id

  class << self
    def create_with_data(flight_id, array, detailed)
      flight = Flight.new
      flight.flight_radar_id = flight_id
      flight.registration_one = array[0]
      flight.registration_two = array[9]
      flight.departure_airport = array[11]
      flight.arrival_airport = array[12]
      flight.aircraft_code = array[8]
      flight.flight_no = array[13]
      flight.call_sign = array[16]
      flight.aircraft_name = detailed['aircraft']
      flight.airline = detailed['airline']
      flight.scheduled_departure = detailed['dep_schd']
      flight.scheduled_arrival = detailed['arr_schd']
      flight.departure_time = detailed['departure']
      flight.arrival_time = detailed['arrival']
      flight.eta = detailed['eta']
      flight.payload = detailed.to_s
      flight
    end

    def by_flight_radar_id(flight_radar_id)
      Flight.where(:flight_radar_id => flight_radar_id).first
    end

    def find_by_snapshot(snapshot)
      result = []
      snapshot_payload = eval(snapshot.payload)
      self.where(:registration_one => snapshot_payload[0], :registration_two => snapshot_payload[9], :aircraft_code => snapshot_payload[8], :call_sign => snapshot_payload[16], :flight_no => snapshot_payload[13], :departure_airport => snapshot_payload[11], :arrival_airport => snapshot_payload[12]).each do |flight|
        result.push flight if flight.in_time? snapshot
      end
      result
    end
  end

  def proper_scheduled_departure
    Time.at self.scheduled_departure
  end

  def proper_scheduled_arrival
    Time.at self.scheduled_arrival
  end

  def proper_departure_time
    Time.at self.departure_time
  end

  def proper_arrival_time
    Time.at self.arrival_time
  end

  def proper_eta
    Time.at self.eta
  end

  def in_time?(snapshot)
    if self.departure_time and self.arrival_time
      (self.proper_departure_time..self.proper_arrival_time).cover?(snapshot.created_at)
    end
  end

end