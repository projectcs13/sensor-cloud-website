json.array!(@groups) do |group|
  json.extract! group, :owner, :name, :description, :tags, :input, :output, :private, :creation_date, :subscribers, :user_ranking
  json.url group_url(group, format: :json)
end