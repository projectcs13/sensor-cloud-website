class Trigger
	include ActiveModel::Model
	include ActiveModel::Validations

	attr_accessor :function, :input, :streams
	#validates :input, :numericality => true
end