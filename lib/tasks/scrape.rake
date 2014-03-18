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
end