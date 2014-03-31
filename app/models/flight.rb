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

    def all_filtered(where='')
      Flight.where("flights.scheduled_departure NOT IN (0) AND flights.scheduled_arrival NOT IN (0) AND flights.flight_no IS NOT NULL AND flights.call_sign IS NOT NULL AND flights.aircraft_code IS NOT NULL AND #{where} (SELECT COUNT(*) FROM `snapshots` WHERE snapshots.flight_id=flights.flight_radar_id AND snapshots.dodgy IS NULL) > 20")
    end
  end

  def proper_snapshots
    @proper_snapshots ||= self.snapshots
  end

  def average_speed
    sum = 0
    proper_snapshots.each do |snapshot|
      sum += snapshot.speed
    end
    if sum == 0
      sum
    else
      sum / proper_snapshots.size
    end
  end

  def average_altitude
    sum = 0
    proper_snapshots.each do |snapshot|
      sum += snapshot.altitude
    end
    if sum == 0
      sum
    else
      sum / proper_snapshots.size
    end
  end

  def average_vertical_speed
    sum = 0
    proper_snapshots.each do |snapshot|
      sum += snapshot.vertical_speed
    end
    if sum == 0
      sum
    else
      sum / proper_snapshots.size
    end
  end

  def average_track
    sum = 0
    proper_snapshots.each do |snapshot|
      sum += snapshot.track
    end
    if sum == 0
      sum
    else
      sum / proper_snapshots.size
    end
  end

  def proper?
    proper_snapshots.size > 15
  end

  def on_time?
    actual_arrival < self.proper_scheduled_arrival-60*5
  end

  def late?
    actual_arrival > self.proper_scheduled_arrival-60*5
  end

  def state
    return 'late' if self.late?
    return 'on_time' if self.on_time?
    'late'
  end

  def actual_departure
    proper_snapshots.first.created_at
  end

  def actual_arrival
    proper_snapshots.last.created_at
  end

  def proper_payload
    eval(self.payload)
  end

  def proper_departure_airport
    @proper_departure_airport ||= Airport.find_by_code self.departure_airport
  end

  def proper_arrival_airport
    @proper_arrival_airport ||= Airport.find_by_code self.arrival_airport
  end

  def proper_scheduled_departure
    @proper_scheduled_departure ||= Time.at self.scheduled_departure || 0
  end

  def proper_scheduled_arrival
    @proper_scheduled_arrival ||= Time.at self.scheduled_arrival || 0
  end

  def proper_departure_time
    @proper_departure_time ||= Time.at self.departure_time || 0
  end

  def proper_arrival_time
    @proper_arrival_time ||= Time.at self.arrival_time || 0
  end

  def proper_eta
    @proper_eta ||= Time.at self.eta || 0
  end

  def proper_scheduled_departure?
    !self.scheduled_departure.nil? and self.scheduled_departure.class.to_s == 'Fixnum' && self.scheduled_departure != 0
  end

  def proper_scheduled_arrival?
    !self.scheduled_arrival.nil? and self.scheduled_arrival.class.to_s == 'Fixnum' && self.scheduled_arrival != 0
  end

  def proper_departure_time?
    !self.departure_time.nil? and self.departure_time.class.to_s == 'Fixnum' && self.departure_time != 0
  end

  def proper_arrival_time?
    !self.arrival_time.nil? and self.arrival_time.class.to_s == 'Fixnum' && self.arrival_time != 0
  end

  def in_time?(snapshot)
    if proper_departure_time? && proper_arrival_time? && proper_scheduled_departure? && proper_scheduled_arrival?
      (self.proper_departure_time-60..self.proper_arrival_time+60).cover?(snapshot.created_at) || (self.proper_scheduled_departure..self.proper_scheduled_arrival).cover?(snapshot.created_at)
    elsif proper_departure_time? && proper_arrival_time?
      (self.proper_departure_time-60..self.proper_arrival_time+60).cover?(snapshot.created_at)
    elsif proper_departure_time? && proper_scheduled_arrival?
      (self.proper_departure_time-60..self.proper_scheduled_arrival+60).cover?(snapshot.created_at)
    elsif proper_scheduled_departure? and proper_arrival_time?
      (self.proper_scheduled_departure-60..self.proper_scheduled_arrival+60).cover?(snapshot.created_at)
    end
  end

end