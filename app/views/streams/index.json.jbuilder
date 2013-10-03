json.array!(@streams) do |stream|
  json.extract! stream, :description, :user_id
  json.url stream_url(stream, format: :json)
end