class Flight < ActiveRecord::Base

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
      Flight.where(:code => flight_radar_id).first
    end
  end

end