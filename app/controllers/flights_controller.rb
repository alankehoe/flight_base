class FlightsController < ApplicationController

  respond_to :json, :xml

  def index
    @flights = Flight.paginate(:page => params[:page])
    respond_with @flights
  end

  def show
    @flight = Flight.find params[:id]
    respond_with @flight
  end

end