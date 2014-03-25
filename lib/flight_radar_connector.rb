require 'net/http'
require 'open-uri'
require 'json'
require 'pony'

class FlightRadarConnector

  def initialize(interval)
    @interval = interval
    @server_host = get_server_host
  end

  def start
    interval_every @interval do
      begin
        @server_host = get_server_host
        get_flights.each do |flight_id, flight_data|
          departure_airport, arrival_airport = Airport.by_airport(flight_data[11]), Airport.by_airport(flight_data[12])
          trackable = flight_in_europe? departure_airport, arrival_airport
          next unless trackable
          flight = Flight.where(:flight_radar_id => flight_id).first
          if flight
            snapshot = Snapshot.create_with_data flight_id, flight_data
            snapshot.save!
            Rails.logger.info "Existing Flight #{flight_id}"
          else
            begin
              detailed_flight_data = get_flight_data flight_id, flight_data[10]
              flight = Flight.create_with_data flight_id, flight_data, detailed_flight_data
              flight.save!
              snapshot = Snapshot.create_with_data flight_id, flight_data
              snapshot.save!
              Rails.logger.info "New Flight #{flight_id}"
            rescue
              Rails.logger.warn "Broke with Flight #{flight_id}"
            end
          end
        end
      rescue
        Rails.logger.fatal 'something really broke!!'
      end
    end
    Pony.mail(:to => 'tsov@me.com', :from => 'tsov@me.com', :subject => 'flight base :/', :body => 'Please have a quick look man!!')
  end

  def flight_in_europe?(departure_airport, arrival_airport)
    arrival_airport and departure_airport and departure_airport.europe? and arrival_airport.europe?
  end

  def get_flights
    url = "http://#{@server_host}/zones/europe_all.js"
    opened = open(url)
    read = opened.read[/{.+}/]
    JSON.parse(read)
  end

  def get_flight_data(flight_id, _)
    url = "http://#{@server_host}/_external/planedata_json.1.4.php?f=#{flight_id}&callback=flight_data_service_cb&_=#{_}"
    opened = open(url)
    read = opened.read[/{.+}/]
    JSON.parse(read)
  end

  def get_server_host
    @server_host = begin
      url = URI.parse('http://www.flightradar24.com/js/_js.php')
      req = Net::HTTP::Get.new(url.path)
      res = Net::HTTP.start(url.host, url.port) do |http|
        http.request(req)
      end
      res.body.match(/var serverForFeed = '(.*?)'/m)[1]
    end
  end

  def interval_every(seconds)
    count = 1
    while true do
      Rails.logger.info "Interval #{count} | Time: #{Time.now}"
      yield
      Rails.logger.info "waiting for #{seconds} seconds"
      Rails.logger.info "Time: #{Time.now}"
      sleep seconds
      count += 1
    end
  end

end