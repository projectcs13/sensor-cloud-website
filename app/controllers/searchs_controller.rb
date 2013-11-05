class SearchsController < ApplicationController

	def new
		conn = Faraday.new(:url => '') do |faraday|
			faraday.request :url_encoded
			faraday.response :logger
			faraday.adapter Faraday.default_adapter
		end

		@response  = conn.get do |req|
			req.url ''
			req.headers['Content-Type'] = 'application/json'
			req.body = ''
		end

		logger.debug "@response: #{@response}"
	end
end
