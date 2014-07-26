require 'json'

# module Api
# 	class << self
class Api

	def self.authenticate
		res = post "/users/_auth/", {}, ""
		res["body"]
	end

	def self.get(url, token)
		url = append_param url, token, "access_token"
		res = connect.get url
		parse_JSON_response res
	end

	def self.get_frontend(url)
		url = append_param url, REFRESH_TOKEN, "refresh_token"
		res = connect.get url
		parse_JSON_response res
	end

	def self.post(url, body, token)
		res = make :post, url, body, token
		parse_JSON_response res
	end

	def self.post_frontend(url, body)
		res = make :post, url, body, REFRESH_TOKEN
		parse_JSON_response res
	end

	def self.put(url, body, token)
		res = make :put, url, body, token
	  parse_JSON_response res
	end

	def self.delete(url, body, token)
		res = make :delete, url, body, token
		parse_JSON_response res
	end

	private
		def self.connect
			conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
			  faraday.request  :url_encoded             # form-encode POST params
			  faraday.response :logger                  # log requests to STDOUT
			  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
			end
		end

		def self.make(method, url, body, token)
			res = connect.send method do |req|
			  req.url url
			  req.headers['Content-Type'] = 'application/json'
			  req.headers['Access-Token'] = token
			  req.body = body.to_json
			end
		end

		def self.parse_JSON_response(res)
			resp = res.to_hash
			resp[:body] = JSON.parse resp[:body]
			resp.stringify_keys!
		end

		def self.append_param(url, token, tokentype)
			char = if url.include? "?" then "&" else "?" end
			url + "#{char}#{tokentype}=" + token
		end

	# end
end
