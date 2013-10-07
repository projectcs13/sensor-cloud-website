class Stream < ActiveRecord::Base
	validates :name, presence: true
end
