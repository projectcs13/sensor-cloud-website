class Resource
  include Her::Model
  attributes :name, :owner
  # has_many :streams
  # validates :name, presence: true
end
