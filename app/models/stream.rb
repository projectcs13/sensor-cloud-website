class Stream
  include Her::Model

  attributes :name
  validates :name, presence: true
	validates :resource_id, presence: true

  belongs_to :resource
  # belongs_to :group

  collection_path "/users/:user_id/resources"
  include_root_in_json false
  parse_root_in_json :hits
end
