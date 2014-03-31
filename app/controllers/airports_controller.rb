class AirportsController < ApplicationController

  respond_to :json, :xml

  def index
    @airports = Airport.where :continent => 'EU'
    puts @airports.size
    respond_with @airports
  end

end