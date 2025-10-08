Geocoder.configure(
  timeout: 5,
  lookup: :nominatim,
  units: :km,
  http_headers: { "User-Agent" => "RailsWeatherApp (contact: example@example.com)" }
)
