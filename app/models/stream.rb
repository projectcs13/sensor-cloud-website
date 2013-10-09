class Stream < ActiveRecord::Base
  belongs_to :resource
  validates :name, presence: true
	validates :resource_id, presence: true
end
