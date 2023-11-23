class UsersController < ApplicationController

	@@STATUS_REQUESTS_LIMIT_FAIL = 429

	before_action :signed_in_user, only: [:edit, :update, :destroy, :profile, :following]
	before_action :correct_user,   only: [:edit, :update]
	before_action :admin_user,     only: :destroy

	def edit
		@user.private = if @user.private == true then "1" else "0" end
	end

	def show
		@user = User.find_by_username params[:id]
		if @user == nil
			redirect_to notfound_path
		else
			res = Api.get "/users/#{@user.username}/streams", openid_metadata
			check_new_token res
			if res["status"] == 401
				flash[:warning] = "Not authorized access to private resources."
				redirect_to "/not_allowed_access"

	    elsif res["status"] == @@STATUS_REQUESTS_LIMIT_FAIL
	      flash[:warning] = res["body"]["error"]
	      redirect_to "/not_allowed_access"

			else
				@streams = res["body"]["streams"]
				@nb_streams = @streams.length if @streams

				res2 = Api.get "/users/#{@user.username}", openid_metadata
				check_new_token res2
		    if res["status"] == @@STATUS_REQUESTS_LIMIT_FAIL
		      flash[:warning] = res["body"]["error"]
		      redirect_to "/not_allowed_access"
		    end

				@notifications = res2["body"]["notifications"]
				sorted = @notifications.sort_by { |hsh| hsh[:timestamp] }.reverse if @notifications
				@notifications = sorted
			end
		end
	end

	def following
		@title = "Following"
		@user = User.find_by_username(params[:id])
		cid = current_user.username
		res = Api.get "/users/#{cid}", openid_metadata
		check_new_token res
		if res["status"] == 401
			flash[:warning] = "Not authorized access to private resources."
			redirect_to "/not_allowed_access"

		elsif res["status"] == @@STATUS_REQUESTS_LIMIT_FAIL
      flash[:warning] = res["body"]["error"]
      redirect_to "/not_allowed_access"

		else
			@subscriptions = res["body"]["subscriptions"]
			unless @subscriptions
				@streams = []
			else
				@stream_ids = @subscriptions.map { |e| e["stream_id"] }
				@streams = @stream_ids.map do |sid|
					res = Api.get "/streams/#{sid}", openid_metadata
					check_new_token res
					res["body"]
				end
			end
		end
	end

	def create
		@user = User.new(user_params)
		params[:user][:private] = !(params[:user][:private].to_i).zero?
		if @user.save
			sign_in @user
			userdata = params[:user].slice(:username, :email, :firstname, :lastname, :description, :private)
			res = Api.post "/users", userdata, {}
			check_new_token res
	    if res["status"] == @@STATUS_REQUESTS_LIMIT_FAIL
	      flash[:warning] = res["body"]["error"]
	      redirect_to "/not_allowed_access"
	    end

			# Store security tokens locally
			@user.access_token = res["body"]["access_token"]
			@user.refresh_token = res["body"]["refresh_token"]
			@user.update_attributes access_token: @user.access_token, refresh_token: @user.refresh_token
			gen_token_pair @user

			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			render 'new'
		end
	end

	def update
		params[:user][:private] = !(params[:user][:private].to_i).zero?
		if @user.update_attributes(user_params)
			flash[:success] = "Account updated"
			@user.save
			userdata = params[:user].slice(:email, :firstname, :lastname, :description, :private)
			res = Api.put "/users/#{@user.username}", userdata, openid_metadata
			if res["status"] == @@STATUS_REQUESTS_LIMIT_FAIL
		    flash[:warning] = res["body"]["error"]
		    redirect_to "/not_allowed_access"
			else
				redirect_to @user
		  end
		else
			render 'edit'
		end
	end

	def destroy
		@user = User.find_by_username(params[:id])
		@user.destroy

		flash[:success] = "User destroyed."
		redirect_to users_url
	end

	private
		def user_params
			params.require(:user).permit(:username, :email, :firstname, :lastname, :description, :private)
		end

		# Before filters
		def signed_in_user
			unless signed_in?
				store_location
				flash[:warning] = "Please sign in"
				redirect_to signin_url
			end
		end

		def correct_user
			@user = User.find_by_username(params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end

		def admin_user
			redirect_to(root_url) unless current_user.admin?
		end

end
