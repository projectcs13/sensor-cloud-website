module SessionsHelper

	def openid_metadata
		{
			:access_token  => session[:token].access_token,
			:refresh_token => session[:token].refresh_token,
			:username      => current_user.username
		}
	end

	def check_new_token res
		if res["body"]["new_access_token"]
			current_user.access_token  = res["body"]["new_access_token"]
			current_user.update_attributes access_token: current_user.access_token
 			gen_token_pair current_user
 		end
	end

	def gen_token_pair(user)
		token_pair = TokenPair.new
		token_pair.access_token  = user.access_token
		token_pair.refresh_token = user.refresh_token
		# token_pair.expires_in    = 3600
		# token_pair.issued_at     = Time.now
		session[:token] = token_pair
	end

	def sign_in(user)
		remember_token = User.new_remember_token
		cookies.permanent[:remember_token] = remember_token
		user.update_attribute("remember_token", User.encrypt(remember_token))
		@current_user = user
	end

	def signed_in?
		!current_user.nil?
	end

	def signed_in_openid?
		current_user.email.end_with? "@openid.ericsson"
	end

	def current_user=(user)
		@current_user = user
	end

	def current_user
		remember_token = User.encrypt(cookies[:remember_token])
		@current_user ||= User.find_by(remember_token: remember_token)
	end

	def current_user?(user)
		user == current_user
	end

	def sign_out
		self.current_user = nil
		cookies.delete(:remember_token)
		session.delete(:state)
		session.delete(:token)
	end

	def redirect_back_or(default)
		redirect_to(session[:return_to] || default)
		session.delete(:return_to)
	end

	def store_location
		session[:return_to] = request.url if request.get?
	end
end
