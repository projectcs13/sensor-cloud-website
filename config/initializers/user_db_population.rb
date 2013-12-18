unless SensorCloud.rake?
	res = Api.get "/users/?admin=true"
	users = res["body"]["users"]
	unless users.nil?
		users.each do | user |
			['id', 'notifications', 'rankings', 'subscriptions', 'triggers'].each { |attr| user.delete attr }
			user['password_confirmation'] = user['password']
			newuser = User.create user
	  	if newuser.save then puts "Saved user with username\n#{newuser.attributes}" end
  	end
	end
end
