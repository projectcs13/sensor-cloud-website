class RelationshipsController < ApplicationController
	#before_action :signed_in_user

	def create
		@stream_id = params[:relationship][:followed_id]
		current_user.follow!(@stream_id)
		#redirect_to @stream
		redirect_to root_path
	end

	def destroy
		@stream_id = Relationship.find(params[:id]).followed_id
		current_user.unfollow!(@stream_id)
		#redirect to @stream
		redirect_to root_path
	end
end
