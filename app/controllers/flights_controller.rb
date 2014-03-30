class FlightsController < ApplicationController

  respond_to :json, :xml

  def index
    puts get_offset
    puts get_offset.class
    @flights = Flight.all_filtered.offset(get_offset).limit(30)
    @pages = (Flight.all_filtered.size / 30).ceil
    respond_with @flights
  end

  def show
    @flight = Flight.find params[:id]
    respond_with @flight
  end

  private

  def get_offset
    if params[:page]
      params[:page].to_i * 30
    else
      0
    end
  end

end