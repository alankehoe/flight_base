class FlightsController < ApplicationController

  respond_to :json, :xml

  def index
    @flights = Flight.paginate(:page => params[:page])
    respond_with @flights
  end

end