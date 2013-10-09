class Stream < ActiveRecord::Base
	validates :name, presence: true
	validates :resource_id, presence: true
	belongs_to :resource
end
