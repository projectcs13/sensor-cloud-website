def save_remote remoteusers
	remoteusers.each do |user|
		fields = ['id', 'notifications', 'rankings', 'subscriptions', 'triggers', 'admin', 'password']
		fields.each { |attr| user.delete attr }

		newuser = User.create user
  	if newuser.save
  		puts "Saved user\n#{newuser.attributes}"
  	else
  		puts "Not saved with username #{newuser.username}"
  	end
	end
end


def delete_old remoteusers
	User.all.each do |user|
		matches = remoteusers.select { |ru| user.username == ru['username'] }
		user.destroy if matches.length == 0
	end
end

def authenticate username
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

	{ refresh_token: refresh_token, access_token: access_token, username: username }
end


unless SensorCloud.rake?
	# TODO Grab this ID from a config file
	frontend_username = "107908217220817548513"		# Frontend unique identifier

	user = User.find_by_username frontend_username
	unless user
		token = authenticate frontend_username
	else
		token = {
      :username      => user.username,
      :access_token  => user.access_token,
      :refresh_token => user.refresh_token
    }
	end

	# Finally, make the token global to be used in other controllers (i.e. "static_pages_controller.rb")
	FRONTEND_TOKEN = token

	# Get all users
	res = Api.get "/users/?admin=true", token
	new_access_token = res["body"]["new_access_token"]

	if new_access_token                                # If there's a new access token, keep it
	  token[:access_token] = new_access_token
		user.save if user.update_attributes access_token: new_access_token
	end

	# Sync local DB with remote data
	users = res["body"]["users"]
	unless users.nil?
		save_remote users
		delete_old users
  end

end
