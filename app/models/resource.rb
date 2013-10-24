class Resource
  include Her::Model

  attributes :name
  # validates :name, presence: true
	validates :name,  presence: true, length: { maximum:50 }

  belongs_to :user
  has_many :streams

  collection_path "/users/:user_id/resources"
  include_root_in_json false
  parse_root_in_json :hits, format: :active_model_serializers
end
