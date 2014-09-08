class TriggersController < ApplicationController

	def new
		@trigger = Trigger.new
		@username = current_user.username

		res = Api.get "/users/#{@username}/streams", openid_metadata
		check_new_token res
		@streams = res['body']['streams']
		@stream_ids = {}
		@streams.each { |e| @stream_ids[e['name']] = e['id'] }

		res = Api.get "/users/#{@username}/vstreams", openid_metadata
		check_new_token res

		logger.debug "*** res (vstreams): #{res} ***"

		@vstreams = res['body']['vstreams']
		@vstream_ids = {}
		@vstreams.each { |e| @vstream_ids[e['name']] = e['id'] }
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
					trigger_params = {'function' => 'span', 'input' => input, 'selected_resource' => trigger_params['selected_resource'], 'streams' => trigger_params['streams'], 'vstreams' => trigger_params['vstreams'] }
				else
					trigger_params = {'function' => 'span', 'input' => input, 'selected_resource' => trigger_params['selected_resource'], 'streams' => trigger_params['streams'], 'vstreams' => trigger_params['vstreams'], 'uri' => trigger_params['uri'] }
				end
			else
				trigger_params['input'] = trigger_params['input'].to_f
			end

			if trigger_params['selected_resource'] == "stream"
				trigger_params['vstreams'] = ""
			else
				trigger_params['streams'] = ""
			end

			trigger_params.delete('selected_resource')

			#if trigger_params.has_key?('streams')
			#	trigger_params['vstreams'] = ""
			#else
			#	trigger_params['streams'] = ""
			#end

			logger.debug "*** create_trigger: #{trigger_params} ***"

			res = Api.post "/users/#{@username}/triggers/add", trigger_params, openid_metadata
			check_new_token res

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
		# @username = current_user.username
		# res = Api.get "/users/#{@username}/triggers", openid_metadata
		logger.debug params
		user_id = params["id"]
		res = Api.get "/users/#{user_id}/triggers", openid_metadata
		check_new_token res
		if res['status'] == 200
			@triggers = res['body']['triggers']
			logger.debug "*** @triggers: #{@triggers} ***"

			@triggers.each do |e|
				if e['streams'].empty?
					e['streams'] = ""
				else
					e['vstreams'] = ""
				end
			end

			res = Api.get "/users/#{user_id}/streams", openid_metadata
			check_new_token res
			@streams = res['body']['streams']
			@stream_names = {}
			@streams.each { |e| @stream_names[e['id']] = e['name'] }

			res = Api.get "/users/#{user_id}/vstreams", openid_metadata
			check_new_token res
			@vstreams = res['body']['vstreams']
			@vstream_names = {}
			@vstreams.each { |e| @vstream_names[e['id']] = e['name'] }

			@functions = {"greater_than" => "Greater than", "less_than" => "Less than", "span" => "Span"}
		end
	end

	def show
	end

	def destroy

		@username = current_user.username
		@trigger = params[:query]
		if @trigger.has_key?("streams") && !@trigger["streams"].empty?
			@trigger['vstreams'] = ""
		else
			@trigger['streams'] = ""
		end
		logger.debug "*** @trigger: #{@trigger} ***"
		if @trigger[:input].kind_of?(String)
			@trigger[:input] = @trigger[:input].to_f
		else
			@trigger[:input].map! { |e| e.to_f }
		end
		@trigger[:uri] = @trigger[:output_id] if @trigger[:output_type] == "uri"
		res = Api.post "/users/#{@username}/triggers/remove", @trigger, openid_metadata
		check_new_token res
		respond_to do |format|
		  format.html { redirect_to :back }
		  format.json { head :no_content }
		end
	end
end
