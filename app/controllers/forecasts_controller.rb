class ForecastsController < ApplicationController
  def new
  end

  def create
    address = params[:address]
    encoded_address = Base64.urlsafe_encode64(address)
    redirect_to forecast_path(encoded_address)
  end

  def show
    encoded = params[:id]
    address = Base64.urlsafe_decode64(encoded) rescue nil

    unless address.present?
      flash[:alert] = "Invalid address"
      redirect_to root_path and return
    end

    location = Geocoder.search(address).first

    unless location
      flash[:alert] = "Unable to find location for '#{address}'"
      redirect_to root_path and return
    end

    zip = Geocoder.search(location.coordinates).first.postal_code
    cache_key = "forecast_#{zip}"

    if (cached_data = Rails.cache.read(cache_key))
      @forecast = cached_data
      @cached = true
    else
      lat, lon = location.coordinates
      # Use OpenWeatherMap API here instead of WeatherForecast gem
      api_key = ENV['OPENWEATHER_API_KEY']
      url = "https://api.openweathermap.org/data/2.5/weather?lat=#{lat}&lon=#{lon}&units=metric&appid=#{api_key}"
      response = HTTParty.get(url)

      if response.success?
        @forecast = response.parsed_response
        Rails.cache.write(cache_key, @forecast, expires_in: 30.minutes)
        @cached = false
      else
        flash[:alert] = "Unable to fetch weather data"
        redirect_to root_path and return
      end
    end
  end
end
