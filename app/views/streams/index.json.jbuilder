json.array!(@streams) do |stream|
  json.extract! stream, :name, :description, :private, :deviation, :longitude, :latitude, :type, :unit, :bound_max, :bound_min, :state, :ranking, :notes
  json.url stream_url(stream, format: :json)
end