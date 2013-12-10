json.array!(@streams) do |stream|
  json.extract! stream, :name, :description, :private, :accuracy, :longitude, :latitude, :stream_type, :unit, :max_val, :min_val, :active, :tags, :resource_id, :user_id, :user_ranking, :history_size, :subscribers
  json.url stream_url(stream, format: :json)
end