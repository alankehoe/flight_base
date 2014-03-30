object @flight => :flight

attributes :id,
           :flight_radar_id,
           :registration_one,
           :registration_two,
           :aircraft_code,
           :aircraft_name,
           :departure_airport,
           :arrival_airport,
           :flight_no,
           :call_sign,
           :airline,
           :payload,
           :created_at,
           :average_speed,
           :average_altitude,
           :state

node :proper_payload do |flight|
  flight.proper_payload
end

node :actual_departure do |flight|
  flight.actual_departure.iso8601
end

node :actual_arrival do |flight|
  flight.actual_arrival.iso8601
end

node :scheduled_departure do |flight|
  flight.proper_scheduled_departure.iso8601
end

node :scheduled_arrival do |flight|
  flight.proper_scheduled_arrival.iso8601
end

node :departure_time do |flight|
  flight.proper_departure_time.iso8601
end

node :arrival_time do |flight|
  flight.proper_arrival_time.iso8601
end

node :eta do |flight|
  flight.proper_eta.iso8601
end

node :proper_departure_airport do |flight|
  partial('flights/_airport', :object => flight.proper_departure_airport)
end

node :proper_arrival_airport do |flight|
  partial('flights/_airport', :object => flight.proper_arrival_airport)
end