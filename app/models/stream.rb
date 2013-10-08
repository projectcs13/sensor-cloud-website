class Stream < ActiveRecord::Base
  belongs_to :resource
  validates :name, presence: true
end
