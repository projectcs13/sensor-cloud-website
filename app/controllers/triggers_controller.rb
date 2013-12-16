class TriggersController < ApplicationController

	def new
		@trigger = Trigger.new
		@username = current_user.username

		res = Api.get("/users/#{@username}/streams")
		@streams = res['body']['streams']
		@stream_ids = {}
		@streams.each { |e| @stream_ids[e['name']] = e['id'] }
	end

	def create
		@username = current_user.username
		trigger_params = params[:trigger]
		#trigger_params['input'] = trigger_params['input'].to_i
		@trigger = Trigger.new(trigger_params)
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

		res = Api.get("/users/#{@username}/streams")
		@streams = res['body']['streams']
		@stream_names = {}
		@streams.each { |e| @stream_names[e['id']] = e['name'] }
		
		@functions = {"greater_than" => "greater than", "less_than" => "less than"}
	end

	def show
	end

	def destroy
		@username = current_user.username
		@trigger = params[:query]
		res = Api.post("/users/#{@username}/triggers/remove", JSON.parse(@trigger))
		respond_to do |format|
			format.html { redirect_to triggers_path }
			format.json { render json: {"deleted" => "ok"}, status: res.status }
		end
	end
end