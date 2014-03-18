class Airport < ActiveRecord::Base

  def europe?
    self.continent == 'EU'
  end

  class << self
    def create_with_data(data)
      airport = Airport.new
      airport.code = data['iata']
      airport.latitude = data['lat']
      airport.longitude = data['lon']
      airport.size = data['size']
      airport.types = data['type']
      airport.continent = data['continent']
      airport.name = data['name']
      airport.status = data['status']
      airport.iso = data['iso']
      airport
    end

    def by_airport(airport_code)
      Airport.where(:code => airport_code).first
    end
  end

end