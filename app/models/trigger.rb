class Trigger
	include ActiveModel::Model
	include ActiveModel::Validations

	attr_accessor :function, :input, :min, :max, :streams, :vstreams, :uri, :selected_resource
	validates 					:input, :numericality => true, 								:allow_nil => true
	validates 					:min, 	:numericality => true, 								:allow_nil => true
	validates 					:max, 	:numericality => true, 								:allow_nil => true
	validates_format_of :uri, 	:with => URI::regexp(%w(http https)), :allow_nil => true
end