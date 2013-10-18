class Resource
  include Her::Model
  include_root_in_json false
  attributes :name
  # has_many :streams
  # validates :name, presence: true

end
