class Stream
  include Her::Model
  include_root_in_json false

  belongs_to :resource
  # belongs_to :group

  validates :name, presence: true
	validates :resource_id, presence: true
end
