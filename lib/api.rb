require 'json'

module Api
	class << self

		def authenticate
			res = post "/users/_auth/", {}, ""
			res["body"]
		end

		def get(url)
			url = append_param url, session[:token], "access_token"
			res = connect.get url
			parse_JSON_response res
		end

		def get_frontend(url)
			url = append_param url, REFRESH_TOKEN, "refresh_token"
			res = connect.get url
			parse_JSON_response res
		end

		def post(url, body)
			res = make :post, url, body, session[:token]
			parse_JSON_response res
		end

		def post_frontend(url, body)
			res = make :post, url, body, REFRESH_TOKEN
			parse_JSON_response res
		end

		def put(url, body)
			res = make :put, url, body, session[:token]
		  parse_JSON_response res
		end

		def delete(url, body)
			res = make :delete, url, body, session[:token]
			parse_JSON_response res
		end

		private
			def connect
				conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
				  faraday.request  :url_encoded             # form-encode POST params
				  faraday.response :logger                  # log requests to STDOUT
				  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
				end
			end

			def make(method, url, body, token)
				res = connect.send method do |req|
				  req.url url
				  req.headers['Content-Type'] = 'application/json'
				  req.headers['Access-Token'] = token
				  req.body = body.to_json
				end
			end

			def parse_JSON_response(res)
				resp = res.to_hash
				resp[:body] = JSON.parse resp[:body]
				resp.stringify_keys!
			end

			def append_param(url, token, tokentype)
				char = if url.include? "?" then "&" else "?" end
				url + "#{char}#{tokentype}=" + token
			end

	end
end
