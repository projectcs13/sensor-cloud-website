unless SensorCloud.rake?
	res = Api.get "/users/?admin=true"
	users = res["body"]["users"]
	unless users.nil?
		users.each do | user |
			['id', 'notifications', 'rankings', 'subscriptions', 'triggers'].each { |attr| user.delete attr }

			## TODO Fix this security issue
			user['password'] = "password" if user['password'] == ""
			## END TODO

			user['password_confirmation'] = user['password']

			newuser = User.create user
	  	if newuser.save
	  		puts "Saved user with username\n#{newuser.attributes}"
	  	else
	  		puts "Not saved with username\n#{newuser.attributes}"
	  	end
  	end
	end
end
