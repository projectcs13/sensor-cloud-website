class Stream
  include Her::Model

  attributes :name
  # validates :name, presence: true
	validates :name,  presence: true, length: { maximum:50 }
	#	validates :resource_id, presence: true

  belongs_to :resource
  # belongs_to :group

  collection_path "/users/:user_id/resources/:resource_id/streams"
  include_root_in_json false
  parse_root_in_json :hits, format: :active_model_serializers
end
