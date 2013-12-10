class RelationshipsController < ApplicationController
	#before_action :signed_in_user

	def custom_create
		@stream_id = params[:followed_id]
		current_user.follow!(@stream_id)

		respond_to do |format|
			format.html { redirect_to root_path }
			format.js
		end
	end

	def custom_destroy
		@stream_id = params[:followed_id]
		current_user.unfollow!(@stream_id)

		respond_to do |format|
			format.html { redirect_to root_path }
			format.js
		end
	end
end
