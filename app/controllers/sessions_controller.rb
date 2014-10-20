class SessionsController < ApplicationController

	before_action :gen_openid_state, only: [:new]

	def new
	end

	def create
		if current_user
			logger.debug "current_user"
			render json: {"url" => "/users/#{current_user.username}/streams"}, status: 200
		else
			# Make sure the state set on the client matches the state previously sent in the request (CSRF)
			if session[:state] != params[:state]
				logger.debug "state does not match"
				render json: {"error" => "The client state does not match the server state."}, status: 401
			else
				sign_out

				fetch_openid_tokens if not session[:token]
				json = fetch_user_info
				user = load_from_db json

				if user
					renew_access_token user
				else
					user = store_user json
					store_on_remote_db user
				end

				logger.debug "before sign in"
				sign_in user
				logger.debug "after sign in"
				render json: {"url" => "/users/#{user.username}/streams"}, status: 200
			end
		end
	end

	def destroy
		sign_out
		revoke_access_token
		redirect_to root_url
	end

	private
		def renew_access_token user
			user.access_token  = session[:token].access_token
			user.refresh_token = session[:token].refresh_token
			user.save
			Api.renew_token user.access_token, user.refresh_token
		end

		def fetch_openid_tokens
			# Upgrade the code into a token object.
			$authorization.code = request.body.read
			$authorization.fetch_access_token!
			$client.authorization = $authorization

			id_token = $client.authorization.id_token
			encoded_json_body = id_token.split('.')[1]
			# Base64 must be a multiple of 4 characters long, trailing with '='
			encoded_json_body += (['='] * (encoded_json_body.length % 4)).join('')
			json_body = Base64.decode64 encoded_json_body
			body = JSON.parse json_body

			# Serialize and store the token in the user's session.
			token_pair = TokenPair.new
			token_pair.update_token! $client.authorization
			session[:token] = token_pair
			puts "token_pair.to_hash"
			puts token_pair.to_hash
		end

		def fetch_user_info
			# Authorize the client and construct a Google+ service.
			$client.authorization.update_token! session[:token].to_hash
			plus = $client.discovered_api 'plus', 'v1'

			# Get the list of people as JSON and return it.
			response = $client.execute!(plus.people.get,
					:collection => 'visible',
					:userId => 'me')

			JSON.parse response.body
		end

		# Disconnect the user by revoking the stored token and removing session objects.
		def revoke_access_token
			if session[:token]
				# Use either the refresh or access token to revoke if present.
				token = session[:token].to_hash[:refresh_token]
				token = session[:token].to_hash[:access_token] unless token

				# You could reset the state at this point, but as-is it will still stay unique
				# to this user and we're avoiding resetting the client state.
				session.delete(:state)
				session.delete(:token)

				# Send the revocation request and return the result.
				revokePath = 'https://accounts.google.com/o/oauth2/revoke?token=' + token
				uri = URI.parse revokePath
				request = Net::HTTP.new uri.host, uri.port
				request.use_ssl = true
				request.get uri.request_uri
			end
		end

		def gen_openid_state
			revoke_access_token
			# Create a string for verification
			session[:state] = (0...13).map{('a'..'z').to_a[rand(26)]}.join unless session[:state]
			@state = session[:state]
		end

		def load_from_db json
			User.find_by_username json["id"]
		end

		def store_user json
			user = User.new
			user.email         = json["emails"][0]["value"]
			user.username      = json["id"]
			user.firstname     = json["name"]["givenName"]
			user.lastname      = json["name"]["familyName"]
			user.image_url     = json["image"]["url"]
			user.description   = "#{json["occupation"]} \n#{json["skills"]}"
			user.private       = false
			user.access_token  = session[:token].access_token
			user.refresh_token = session[:token].refresh_token
			user.save
			user
		end

		def store_on_remote_db user
			data = {}
			attrs = ["username", "email", "firstname", "lastname", "description", "private"]
			attrs.each do |attr| data[attr] = user.send(attr) end
			data["access_token"]  = session[:token].access_token
			data["refresh_token"] = session[:token].refresh_token
			res = Api.post "/users", data, {}
			puts res
			res
		end
end
