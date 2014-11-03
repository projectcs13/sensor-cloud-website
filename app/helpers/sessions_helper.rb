module SessionsHelper

	def openid_metadata
		unless current_user
			FRONTEND_TOKEN
		else
			{
				:access_token  => current_user.access_token,
				:refresh_token => current_user.refresh_token,
				:username      => current_user.username
			}
		end
	end

	def openid_frontend_metadata
		FRONTEND_TOKEN
	end

	def check_new_token res
		if current_user then check_new_token_normal res else check_new_token_frontend res	end
	end

	def check_new_token_normal res
		logger.debug "check_new_token"
		if res["new_access_token"]
			current_user.access_token = res["new_access_token"]
			current_user.save
 			gen_token_pair current_user
 		end
	end

	def check_new_token_frontend res
		logger.debug "check_new_token_frontend"
		if res["new_access_token"]
			frontend = User.find_by_username FRONTEND_TOKEN['username']
			frontend.access_token = res["new_access_token"]
			frontend.save
 		end
	end

	def gen_token_pair user
		token_pair = TokenPair.new
		token_pair.access_token  = user.access_token
		token_pair.refresh_token = user.refresh_token
		token_pair.expires_in    = 3600
		token_pair.issued_at     = Time.now
		session[:token] = token_pair
	end

	def sign_in user
		logger.debug "Sign in yaay"
		remember_token = User.new_remember_token
		logger.debug "remember_token"
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute("remember_token", User.encrypt(remember_token))
		# user.update_attributes(:remember_token => User.encrypt(remember_token), :access_token => user)
		@current_user = user
	end

	def signed_in?
		!current_user.nil?
	end

	def current_user= user
		@current_user = user
	end

	def current_user
		remember_token = User.encrypt(cookies.permanent[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token)
	end

	def current_user? user
		user == current_user
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
		session.delete(:state)
		session.delete(:token)
	end

	def redirect_back_or default
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get?
	end
end
