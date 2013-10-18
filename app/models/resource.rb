class Resource
  include Her::Model
  include_root_in_json false

  attributes :name
  validates :name, presence: true

  has_many :streams
end
