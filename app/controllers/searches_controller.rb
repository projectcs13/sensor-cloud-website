class SearchesController < ApplicationController

	@@STATUS_REQUESTS_LIMIT_FAIL = 429

	before_action :get_credentials, only: [:update_user_ranking, :fetgh_graph_data, :fetch_autocomplete, :create]

	def show
	end

	def filter
	end

	def update_user_ranking
		body = { user_id: current_user.username, ranking: params[:json][:value] }
		res = Api.put "/streams/#{params[:json][:stream_id]}/_rank", body, @credentials
		check_new_token res
		respond_to do |format|
			format.json { render json: res["body"], status: res["status"] }
		end
	end

	def fetch_graph_data
		res = Api.get "/_history?stream_id=#{params[:stream_id]}", @credentials
		check_new_token res
		respond_to do |format|
			format.json { render json: res["body"], status: 200 }
		end
	end

	def fetch_autocomplete
		res = Api.get "/suggest/_search?query=#{params[:term]}", @credentials
		check_new_token res
		respond_to do |format|
			format.json { render json: res["body"]["suggestions"], status: 200 }
		end
	end

	def create
		@query = params['search']['query']
		if @query.blank? or @query == "" then
			@filter_unit = params['search']['filter_unit']
			@filter_tag = params['search']['filter_tag']
			@filter_longitude = params['search']['filter_longitude']
			@filter_latitude = params['search']['filter_latitude']
			@filter_distance = params['search']['filter_distance']
			@filter_active = params['search']['filter_active']

			@streams = []
			@users = []
			@count_streams = nil
			@count_users = nil
			@count_all = nil
			@query = params['search']['query']
	        render :action => 'show'
		else
			@nb_results_per_page = 8
			@page_number = params['search']['page'].to_i
			query_from = @page_number * @nb_results_per_page
			url = "/_search?location=true&from=#{query_from}&size=#{@nb_results_per_page.to_i}"
			sort_by = if params['search']['sort_by'] == "name" then { "stream.name.untouched" => "asc" } else { "average" => "desc" } end
		    tags = params['search']['filter_tag'].split(",") unless params['search']['filter_tag'].nil? or params['search']['filter_tag'].blank?
		    filters = Array.new
		    filters.push({ "regexp" => { "unit" => { "value" => params['search']['filter_unit'] } } }) unless params['search']['filter_unit'].nil? or params['search']['filter_unit'].blank?
		    filters.push({ "regexp" => { "active" => { "value" => params['search']['filter_active'] } } }) unless params['search']['filter_active'] == "any" or params['search']['filter_active'].blank?
		    filters.push({ "terms" => { "tags" =>  tags } }) unless tags.nil?
		    filters.push({ "geo_distance" => { "distance" => params['search']['filter_distance'] + "km" , "stream.location" => { "lat" => params['search']['filter_latitude'] , "lon" => params['search']['filter_longitude'] } } }) unless params['search']['filter_longitude'].nil? or params['search']['filter_longitude'].blank?
			if filters.empty?
				body = { "sort" => sort_by, "query" =>
							    { "query_string" =>
										{ "query" => params['search']['query'] }
								  }
								}
			else
				body = { "sort" => sort_by, "query" =>
									{ "filtered" =>
										{ "query" =>
											{ "query_string" =>
												{ "query" =>
													params['search']['query']
												}
											}, "filter" =>
											{
												"and" => filters
											}
										}
									}
								}
			end
			res = Api.post url, body, @credentials
			check_new_token res
			if res["status"] == @@STATUS_REQUESTS_LIMIT_FAIL
				flash[:warning] = "Not authorized access to private resources."
				redirect_to "/not_allowed_access"
			else
				@filter_unit = params['search']['filter_unit']
				@filter_tag = params['search']['filter_tag']
				@filter_longitude = params['search']['filter_longitude']
				@filter_latitude = params['search']['filter_latitude']
				@filter_distance = params['search']['filter_distance']
				@filter_active = params['search']['filter_active']

				@streams = []
	  		@streams_raw = res["body"]['streams']['hits']['hits']
	  		@streams_raw.each do |s|
	   		 	data = s['_source']
	    		data['id'] = s['_id']
	    		@streams.push data
	  		end

				# @vstreams = res["body"]['vstreams']['hits']['hits']

				@users = res["body"]['users']['hits']['hits']
				# @count_vstreams = res["body"]['vstreams']['hits']['total']

				logger.debug res["body"]['streams']

				@count_streams = res["body"]['streams']['hits']['total']
				@count_users = res["body"]['users']['hits']['total']
				# @count_all = @count_streams + @count_users + @count_vstreams
				@query = params['search']['query']

	      if @page_number > 0
	        respond_to { |format| format.js }
	      else
	       	render :action => 'show'
	    	end
	    end
		end
	end

	private
		def get_credentials
			@credentials = if current_user then openid_metadata else openid_frontend_metadata end
		end
end
