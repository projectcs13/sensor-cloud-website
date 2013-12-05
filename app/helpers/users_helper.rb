module UsersHelper

	# Returns the Gravatar (http://gravatar.com/) for the given user.
	def gravatar_for(user, options = { size: 32 })
		gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
		size = options[:size]
		gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
		image_tag(gravatar_url, alt: user.username, class: "gravatar")
	end
	
	def gravatar_for_profile(user, options = { size: 250 })
		gravatar_id = Digest::MD5::hexdigest(user.email.downcase)
		size = options[:size]
		gravatar_url = "https://secure.gravatar.com/avatar/#{gravatar_id}?s=#{size}"
		image_tag(gravatar_url, alt: user.username, class: "img-rounded")
	end

	def emptydescription(user)
    			if @user.description.blank? && @user.username == current_user.username
       				link_to "Edit your Profile", edit_user_path(current_user) 
    			else
      				@user.description
    			end  

  end
end
