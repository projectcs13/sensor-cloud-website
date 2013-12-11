require 'json'

module Api
	class << self

		def connect
			conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
			  faraday.request  :url_encoded             # form-encode POST params
			  faraday.response :logger                  # log requests to STDOUT
			  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
			end
		end

		def get(url)
			res = connect.get(url)
			resp = { "body" => JSON.parse(res.body), "status" => res.status}
		end

		def post(url, body)
			res = connect.post do |req|
			  req.url url
			  req.headers['Content-Type'] = 'application/json'
			  req.body = body.to_json
			end
			resp = { "body" => JSON.parse(res.body), "status" => res.status}
		end

		def put(url, body)
			res = connect.put do |req|
			  req.url url
			  req.headers['Content-Type'] = 'application/json'
			  req.body = body.to_json
			end
		  resp = { "body" => JSON.parse(res.body), "status" => res.status}
		end

	end
end