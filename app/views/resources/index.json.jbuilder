json.array!(@resources) do |resource|
  json.extract! resource, :owner, :name, :description, :manufacturer, :model, :privacy, :notes, :last_updated, :creation_date, :update_freq, :resource_type
  json.url resource_url(resource, format: :json)
end