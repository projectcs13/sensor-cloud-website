class Resource < ActiveRecord::Base
  has_many :streams

  validates :name, presence: true
end
