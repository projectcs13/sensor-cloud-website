require 'json'

module Api
	class << self

		def authenticate
			res = post "/users/_auth/", {}, ""
			res["body"]
		end

		def append_param(url, token, tokentype)
			char = if url.include? "?" then "&" else "?" end
			url + "#{char}#{tokentype}=" + token
		end

		def _get(url, token, tokentype)
			url = append_param url, token, tokentype
			res = connect.get url
			parse_JSON_response res
		end

		def get(url)
			_get url, REFRESH_TOKEN, "refresh_token"
		end

		def post(url, body)
			_post(url, body, REFRESH_TOKEN)
		end

		def _post(url, body, token)
			res = make :post, url, body, token
			parse_JSON_response res
		end

		def put(url, body)
			_put(url, body, REFRESH_TOKEN)
		end

		def _put(url, body, token)
			res = make :put, url, body, token
		  parse_JSON_response res
		end

		def delete(url, body)
			_delete(url, body, REFRESH_TOKEN)
		end

		def _delete(url, body, token)
			res = make :delete, url, body, token
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

	end
end
