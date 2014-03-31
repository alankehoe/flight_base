class FlightsController < ApplicationController

  respond_to :json, :xml

  def index
    @flights = Flight.all_filtered.order("id DESC").offset(get_offset).limit(30)
    @pages = (Flight.all_filtered.size / 30).ceil
    respond_with @flights
  end

  def show
    @flight = Flight.find params[:id]
    respond_with @flight
  end

  def probability
    construct_attributes
    @hash = {'late' => 0, 'on_time' => 0}
    Flight.all_filtered(construct_airport_filter).find_each do |flight|
      @hash[flight.state] += 1
    end
    @hash['size'] = Flight.all_filtered(construct_airport_filter).size
    respond_with @hash
  end

  def prediction
    construct_attributes
    neighbors = []
    Flight.all_filtered(construct_airport_filter).find_each do |flight|
      value = distance flight
      neighbors.push([value, flight])
      neighbors.sort!.pop if neighbors.size > 5
    end
    counts = {'on_time' => 0, 'late' => 0}
    neighbors.each do |neighbor|
      counts[neighbor.last.state] += 1
    end
    state = 'nothing'
    state = 'on_time' if counts['on_time'] > counts['late']
    state = 'late' if counts['late'] > counts['on_time']
    @body = { :state => state, :result => neighbors }
    respond_with @body
  end

  private

  def get_offset
    if params[:page]
      params[:page].to_i * 30
    else
      0
    end
  end

  def distance(flight)
    value = 0
    @existing_params.each do |parameter|
      value += (flight.send("average_#{parameter}".to_sym) - params[parameter]).power!(2)
    end
    Math.sqrt value
  end

  def construct_airport_filter
    string = ''
    ['departure_airport', 'arrival_airport'].each do |attribute|
      if params[attribute] && !params[attribute].empty?
        string << "flights.#{attribute}='#{params[attribute]}' AND "
      end
    end
    string
  end

  def construct_attributes
    @existing_params = []
    ['speed', 'vertical_speed', 'track', 'altitude'].each do |attribute|
      if params[attribute] && !params[attribute].empty?
        params[attribute] = params[attribute].to_i
        @existing_params.push attribute
      end
    end
  end

end