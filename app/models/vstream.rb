class Vstream
  include Her::Model

  attributes :name, :description, :user_id, :function, :streams_involved, :starting_date, :tags
	validates :name,  presence: true, length: { maximum:50 }

  belongs_to :user

  collection_path "vstreams"
  include_root_in_json false
  parse_root_in_json :vstreams, format: :active_model_serializers
end
