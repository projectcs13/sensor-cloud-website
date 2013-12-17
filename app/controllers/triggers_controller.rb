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
			if !(trigger_params['min'].nil? || trigger_params['max'].nil?)
				trigger_params['min'] = trigger_params['min'].to_f
				trigger_params['max'] = trigger_params['max'].to_f
				input = [trigger_params['min'], trigger_params['max']]
				if trigger_params['uri'].nil? 
					trigger_params = {'function' => 'span', 'input' => input, 'streams' => trigger_params['streams'] }
				else
					trigger_params = {'function' => 'span', 'input' => input, 'streams' => trigger_params['streams'], 'uri' => trigger_params['uri'] }
				end
			else
				trigger_params['input'] = trigger_params['input'].to_f
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
		if @trigger[:input].kind_of?(String)
			@trigger[:input] = @trigger[:input].to_f
		else
			@trigger[:input].map! { |e| e.to_f }
		end
		@trigger[:uri] = @trigger[:output_id] if @trigger[:output_type] == "uri"
		res = Api.post("/users/#{@username}/triggers/remove", @trigger)
		respond_to do |format|
			format.html { redirect_to triggers_path }
			format.json { render json: {"deleted" => "ok"}, status: res.status }
		end
	end
end