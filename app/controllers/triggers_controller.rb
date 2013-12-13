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
		trigger_params = params[:trigger]
		#trigger_params['input'] = trigger_params['input'].to_i
		@trigger = Trigger.new(trigger_params)
		logger.debug "*** @trigger: #{@trigger.valid?} ***"
		if @trigger.valid?
			res = Api.post("/users/#{@username}/triggers/add", trigger_params)
			respond_to do |format|
				format.html { redirect_to triggers_path }
			end
		else
			respond_to do |format|
				format.html { redirect_to triggers_new_path }
			end
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