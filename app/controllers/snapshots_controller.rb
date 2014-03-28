class SnapshotsController < ApplicationController

  respond_to :json, :xml

  def index
    flight = Flight.find params[:flight_id]
    @snapshots = flight.snapshots
    respond_with @snapshots
  end

end