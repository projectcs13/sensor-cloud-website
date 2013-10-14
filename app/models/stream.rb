class Stream < ActiveRecord::Base
  belongs_to :resource
  belongs_to :group

  validates :name, presence: true
	validates :resource_id, presence: true
end
