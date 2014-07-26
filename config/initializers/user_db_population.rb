unless SensorCloud.rake?

	# Frontend unique identifier
	user = User.find_by_username "107908217220817548513"
	refresh_token = if user then user.refresh_token else nil end

	if refresh_token
		REFRESH_TOKEN = refresh_token 	# Convert the var into a public constant
	else
		# Frontend performs API's Authentication
		puts "There is not any refresh_token available locally to perform authenticated API calls."
		puts "Authenticating..."

		token_url = Api.authenticate
		puts "Open the next url with the browser:"
		puts token_url

		puts "\nCopy and type here the Refresh Token"
		REFRESH_TOKEN = gets.chomp
	end

	# Once we have the token, the whole list users will be downloaded
	# Then, we will store locally the token forever

	# Get all users
	# res = Api.get "/users/?admin=true", REFRESH_TOKEN, "refresh_token"
	res = Api.get_frontend "/users/?admin=true"
	users = res["body"]["users"]
	unless users.nil?
		users.each do |user|
			fields = ['id', 'notifications', 'rankings', 'subscriptions', 'triggers', 'admin']
			fields.each { |attr| user.delete attr }

			## TODO Fix this security issue
			user['password'] = "password" if user['password'] == ""
			user['password_confirmation'] = user['password']
			## END TODO

			# if user['email'] != "107908217220817548513@openid.ericsson"
			# 	newuser = User.create user
			newuser = User.create user
	  	if newuser.save
	  		puts "Saved user\n#{newuser.attributes}"
	  	else
	  		puts "Not saved with username #{newuser.username}"
	  	end
		end
  end

end
