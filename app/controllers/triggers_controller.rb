class TriggersController < ApplicationController

	def index
		@username = current_user.username
		res = Api.get("/users/#{@username}/triggers")
		@triggers = res['body']['triggers']
		logger.debug "*** @triggers: #{@triggers} ***"
	end

	def show
	end

	def destroy
		@username = current_user.username
		@trigger = params[:query]
		logger.debug "*** @trigger: #{@trigger} ***"
		res = Api.post("/users/#{@username}/triggers/remove", JSON.parse(@trigger))
		respond_to do |format|
			format.html { redirect_to triggers_path }
		end
	end
end