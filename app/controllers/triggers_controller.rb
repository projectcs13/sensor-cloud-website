class TriggersController < ApplicationController

	def index
		@username = current_user.username
		res = Api.get("/users/#{@username}/triggers")
		@triggers = res['body']['triggers']
		logger.debug "*** @triggers: #{@triggers} ***"
	end

	def show
	end

	def custom_destroy
		@trigger = params[:query]
		logger.debug "*** @trigger: #{@trigger} ***"
	end
end