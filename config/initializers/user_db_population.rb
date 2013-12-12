res = Api.get "/users/?admin=true"
res["body"]["users"].each do | user |
	user.delete 'notifications'
	user.delete 'rankings'
	user.delete 'subscriptions'
	user.delete 'triggers'
	user.delete 'private'
	user.delete 'id'
	user['password_confirmation'] = user['password']
	newuser = User.create(user)
	puts newuser.attributes
	if newuser.save then 
		puts "Saved user with username (#{user['username']})"
	else
		puts "Not Saved"
	end
end
