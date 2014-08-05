def download(remoteusers)
	remoteusers.each do |user|
		fields = ['id', 'notifications', 'rankings', 'subscriptions', 'triggers', 'admin']
		fields.each { |attr| user.delete attr }

		## TODO Fix this security issue
		user['password'] = "password" if user['password'] == ""
		user['password_confirmation'] = user['password']
		## END TODO

		newuser = User.create user
  	if newuser.save
  		puts "Saved user\n#{newuser.attributes}"
  	else
  		puts "Not saved with username #{newuser.username}"
  	end
	end
end


def delete_old(remoteusers)
	User.all.each do |user|
		matches = remoteusers.select { |ru| user.username == ru['username'] }
		user.destroy if matches.length == 0
	end
end

def authenticate
	# Frontend performs API's Authentication
	puts "There is not any refresh_token available locally to perform authenticated API calls."
	puts "Authenticating..."

	token_url = Api.authenticate
	puts "Open the next url with the browser:"
	puts token_url

	puts "\nCopy and type here the Access Token"
	access_token = gets.chomp

	puts "\nCopy and type here the Refresh Token"
	refresh_token = gets.chomp

	{ :refresh_token => refresh_token, :access_token => access_token }
end

unless SensorCloud.rake?
	FRONTEND_USERNAME = "107908217220817548513"		# Frontend unique identifier

	user = User.find_by_username FRONTEND_USERNAME
	refresh_token = if user then user.refresh_token else nil end
	access_token  = if user then user.access_token  else nil end

	unless (access_token and refresh_token)
		tokens = authenticate
		access_token  = tokens[:access_token]
		refresh_token = tokens[:refresh_token]
	end

	# Get all users
	res = Api.get "/users/?admin=true", access_token
	if res["status"] != 200		                         # If the access token is old, renew it
		res = Api.renew_access_token refresh_token
		access_token = res["body"]["access_token"]
		if user.update_attributes access_token: access_token then user.save end
		res = Api.get "/users/?admin=true", access_token
		if res["status"] != 200											     # If response is not ok yet, there are no remote users
			tokens = authenticate                          # Then, authenticate on the backend
			access_token  = tokens[:access_token]
			refresh_token = tokens[:refresh_token]
		end
	end

	ACCESS_TOKEN = access_token   # Convert the var into a public constant

	remote_users = res["body"]["users"]								 # Sync local DB with remote
	unless remote_users.nil?
		download remote_users
		delete_old remote_users
  end

end
