class Group < ActiveRecord::Base
  has_many :streams
  belongs_to :user

  validates :name,  presence: true
end
