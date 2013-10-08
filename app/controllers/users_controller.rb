class UsersController < ApplicationController
	before_action :signed_in_user, only: [:edit, :update]
	before_action :correct_user, 	 only: [:edit, :update]

	def show
		@user = User.find(params[:id])
	end

	def new
		@user = User.new
  end

	def create
		@user = User.new(user_params)
		if @user.save
			sign_in @user
			flash[:success] = "Welcome to the Sample App!"
			redirect_to @user
		else
			render 'new'
		end
	end

	def edit
	end

	def update
		if @user.update_attributes(user_params)
			flash[:success] = "Profile updated"
			redirect_to @user
		else
			render 'edit'
		end
	end

	private

		def user_params
			params.require(:user).permit(:name, :email, :password, 
																		 :password_confirmation)
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
			@user = User.find(params[:id])
			redirect_to(root_url) unless current_user?(@user)
		end
end
