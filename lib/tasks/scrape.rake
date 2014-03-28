require Rails.root + 'lib/flight_radar_connector'
require Rails.root + 'lib/airport_connector'
require 'pp'

namespace :scrape do
  desc "Scrape data from FlightRadar24"
  task :flights => :environment do
    flight_radar = FlightRadarConnector.new 60*1
    flight_radar.start
  end

  desc "Scrape airport data"
  task :airports => :environment do
    airport_connector = AirportConnector.new
    airport_connector.start
  end

  desc "Repair lost snapshots"
  task :repair_snapshots => :environment do
    ok_count = 0
    too_many_count = 0
    too_little_count = 0
    recovered_flights = Set.new
    Snapshot.where("`flight_id`='2'").find_each do |snapshot|
      begin
        puts '----------------'
        flights = Flight.find_by_snapshot(snapshot)
        pp snapshot
        flights.each do |flight|
          puts '--'
          puts "Flight id: #{flight.id}"
          puts "Scheduled Dep: #{flight.proper_scheduled_departure}"
          puts "Scheduled Arr: #{flight.proper_scheduled_arrival}"
          puts "Dep: #{flight.proper_departure_time}"
          puts "Arr: #{flight.proper_arrival_time}"
          pp flight
          puts '--'
        end
        if flights.size == 1
          ok_count += 1
          recovered_flights << flights.first
          snapshot.flight_id = flights.first.flight_radar_id
          snapshot.dodgy = true
          snapshot.save!
        elsif flights.size == 0
          too_little_count += 1
        else
          too_many_count += 1
        end
        puts '----------------'
      rescue
        puts 'rescued'
      ensure
        puts "perfect:  #{ok_count}"
        puts "too little: #{too_little_count}"
        puts "too many: #{too_many_count}"
        puts "recovered flights: #{recovered_flights.size}"
      end
    end
    puts "perfect:  #{ok_count}"
    puts "too little: #{too_little_count}"
    puts "too many: #{too_many_count}"
    puts "recovered flights: #{recovered_flights.size}"
  end
end