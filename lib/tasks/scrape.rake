require Rails.root + 'lib/flight_radar_connector'
require Rails.root + 'lib/airport_connector'

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
    count = 0
    recovered_flights = Set.new
    while (snapshots = Snapshot.offset(count).limit(100)).size > 0
      snapshots.each do |snapshot|
        begin
          flights = Flight.find_by_snapshot(snapshot)
          if flights.size == 1
            ok_count += 1
            recovered_flights << flights.first
            snapshot.flight_id = flights.first.flight_radar_id
            snapshot.save!
          elsif flights.size == 0
            too_little_count += 1
          else
            too_many_count += 1
          end
        rescue
          puts 'rescued'
        ensure
          puts "perfect:  #{ok_count}"
          puts "too little: #{too_little_count}"
          puts "too many: #{too_many_count}"
          puts "recovered flights: #{recovered_flights.size}"
        end
      end
      puts count
      count += 100
    end
    puts "perfect:  #{ok_count}"
    puts "too little: #{too_little_count}"
    puts "too many: #{too_many_count}"
    puts "recovered flights: #{recovered_flights.size}"
  end
end