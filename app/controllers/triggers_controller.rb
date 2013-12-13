class TriggersController < ApplicationController

	def new
		@trigger = Trigger.new
		@username = current_user.username
		res = Api.get("/users/#{@username}/streams")
		@streams = res['body']['streams']
		logger.debug "*** @streams: #{@streams}***"
		@stream_ids = @streams.map { |e| e['id'] }
		logger.debug "*** @stream_ids: #{@stream_ids} ***"
	end

	def create
		@username = current_user.username
		trigger = params[:trigger]
		trigger['input'] = trigger['input'].to_i
		logger.debug "*** trigger: #{trigger} ***"
		res = Api.post("/users/#{@username}/triggers/add", trigger)
		respond_to do |format|
			format.html { redirect_to triggers_path }
		end
	end

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