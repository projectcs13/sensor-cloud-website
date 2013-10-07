class Stream < ActiveRecord::Base
	validates :longitude, numericality: true
	validates :latitude, numericality: true
end
