class SessionsController < ApplicationController

	before_action :create_openid_state, only: [:new]

	def new
	end

	def create
		user = User.find_by(email: params[:session][:email].downcase)
		if user && user.authenticate(params[:session][:password])
			sign_in user
			redirect_back_or user
		else
			flash.now[:danger] = 'Invalid email/password combination'
			render 'new'
		end
	end

	def destroy
		revoke_access_token if signed_in_openid?
		sign_out
		redirect_to root_url
	end

	def auth_openid_connect
		if current_user
			logger.debug "current_user"
			render json: {"url" => "/users/#{current_user.username}/streams"}, status: 200
		else
			# Make sure the state set on the client matches the state previously sent in the request (CSRF)
			if session[:state] != params[:state]
				logger.debug "state does not match"
				render json: {"error" => "The client state does not match the server state."}, status: 401
			else
				fetch_access_token if not session[:token]
				# fetch_access_token
				json = fetch_user_info
				user = load_from_db json

				if not user
					user = store_user json
					store_on_remote_db user
				end

				sign_in user
				logger.debug "user signed in"
				logger.debug "Signed_in? #{signed_in?}"
				render json: {"url" => "/users/#{user.username}/streams"}, status: 200
			end
		end
	end

	def auth_openid_disconnect
		revoke_access_token
		render json: {"success" => "true"}, status: 200
	end

	private
		def fetch_access_token
			# Upgrade the code into a token object.
			$authorization.code = request.body.read
			$authorization.fetch_access_token!
			$client.authorization = $authorization

			id_token = $client.authorization.id_token
			encoded_json_body = id_token.split('.')[1]
			# Base64 must be a multiple of 4 characters long, trailing with '='
			encoded_json_body += (['='] * (encoded_json_body.length % 4)).join('')
			json_body = Base64.decode64(encoded_json_body)
			body = JSON.parse(json_body)
			# You can read the Google user ID in the ID token.
			# "sub" represents the ID token subscriber which in our case
			# is the user ID. This sample does not use the user ID.
			gplus_id = body['sub']

			# Serialize and store the token in the user's session.
			token_pair = TokenPair.new
			token_pair.update_token!($client.authorization)
			session[:token] = token_pair
		end

	def fetch_user_info
		# Authorize the client and construct a Google+ service.
		$client.authorization.update_token!(session[:token].to_hash)
		plus = $client.discovered_api('plus', 'v1')

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

	def create_openid_state
		revoke_access_token
		# Create a string for verification
		session[:state] = (0...13).map{('a'..'z').to_a[rand(26)]}.join unless session[:state]
		@state = session[:state]
	end

	def store_user(json)
		user = User.new
		user.email = json["id"] + "@openid.ericsson"
		user.username = json["id"]
		user.firstname = json["name"]["givenName"]
		user.lastname = json["name"]["familyName"]
		user.description = ""
		user.password = "pa55w0rd"
		user.private = false
		user.save
		user
	end

	def load_from_db(json)
		user_email = json["id"] + "@openid.ericsson"
		User.find_by_email user_email
	end

	def store_on_remote_db(user)
		# data = user.attributes.slice("username", "email", "password", "firstname", "lastname", "description", "private")
		data = {}
		attrs = ["username", "email", "password", "firstname", "lastname", "description", "private"]
		attrs.each do |attr| data[attr] = user.send(attr) end
		data["access_token"] = session[:token].to_hash[:access_token]
		Api.post "/users", data
	end
end
