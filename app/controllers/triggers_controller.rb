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
		@trigger = Trigger.new(trigger_params)
		if @trigger.valid?
			unless (trigger_params['min'].nil? || trigger_params['max'].nil?)
				input = [trigger_params['min'], trigger_params['max']]
				trigger_params = {'function' => 'span', 'input' => input, 'streams' => trigger_params['streams']}
			end
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
		
		@functions = {"greater_than" => "Greater than", "less_than" => "Less than", "span" => "Span"}
	end

	def show
	end

	def destroy
		@username = current_user.username
		@trigger = params[:query]
		res = Api.post("/users/#{@username}/triggers/remove", @trigger)
		respond_to do |format|
			format.html { redirect_to triggers_path }
		end
	end
end