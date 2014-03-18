require 'net/http'
require 'open-uri'
require 'json'

class AirportConnector

  def start
    airports = get_airports
    airports.each do |airport_data|
      airport = Airport.create_with_data airport_data
      airport.save!
    end
  end

  def get_airports
    url = URI.parse('https://raw.github.com/jbrooksuk/JSON-Airports/master/airports.json')
    req = Net::HTTP::Get.new(url.path)
    res = Net::HTTP.start(url.host, url.port, :use_ssl => url.scheme == 'https') do |http|
      http.request(req)
    end
    JSON.parse res.body rescue []
  end

end