class Trigger
	include ActiveModel::Model
	include ActiveModel::Validations

	attr_accessor :function, :input, :min, :max, :streams
	validates :input, :numericality => true, :allow_nil => true
	validates :min, :numericality => true, :allow_nil => true
	validates :max, :numericality => true, :allow_nil => true
end