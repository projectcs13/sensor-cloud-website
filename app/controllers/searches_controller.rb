class SearchesController < ApplicationController

	def show
	end

	def filter
	end

	def update_user_ranking
		res = Api.put(
			"/streams/#{params[:json][:stream_id]}/_rank", 
			{ user_id: current_user.username, ranking: params[:json][:value] }
		)

		respond_to do |format|
			format.json { render json: res["body"], status: res["status"] }
		end
	end

	def fetch_graph_data
		res = Api.get("/_history?stream_id=#{params[:stream_id]}")
		respond_to do |format|
			format.json { render json: res["body"], status: 200 }
		end
	end

	def fetch_autocomplete
		res = Api.get("/suggest/_search?query=#{params[:term]}")
		respond_to do |format|
			format.json { render json: res["body"]["suggestions"], status: 200 }
		end
	end

	def create
		@nb_results_per_page = 8.0
		if params['search']['query'].blank?
			redirect_to root_path
		else

			if (not params['search']['page'].blank?)
				url = "/_search?location=true&from=#{(params['search']['page'].to_i)*(@nb_results_per_page.to_i)}&size=#{@nb_results_per_page.to_i}"
			elsif (not params['search']['page_users'].blank?)
				url = "/_search?location=true&from=#{(params['search']['page_users'].to_i)*(@nb_results_per_page.to_i)}&size=#{@nb_results_per_page.to_i}"
			else
				url = "/_search?location=true&from=0&size=#{@nb_results_per_page.to_i}"
			end

			if params['search']['sort_by'] == "none"
				sort_by = '{}'
			elsif params['search']['sort_by'].nil?
				sort_by = '{"average":"desc"}'
			else
				sort_by = '{"' + params['search']['sort_by'] + '":"desc" }'
			end

			filters = Array.new
			if params['search']['filter_unit'].to_s.strip.length != 0
				nameFilter = {"regexp"=>{ "unit" => { "value" => params['search']['filter_unit'] }}}
				filters.push(nameFilter.to_json)
			end
			if params['search']['filter_tag'].to_s.strip.length != 0
					tagFilter = {"regexp"=>{ "tags" => { "value" => params['search']['filter_tag'] }}}
					filters.push(tagFilter.to_json)
			end
			if params['search']['filter_rank'] == "1"
					rankFilter = {"range"=>{ "user_ranking.average" => {"gte" => params['search']['min_val'] , "lte" => params['search']['max_val']}}}
					filters.push(rankFilter.to_json)
			end
			if params['search']['filter_active'] == "1"
						activeFilter = {"regexp"=>{ "active" => { "value" => params['search']['active'] }}}
						filters.push(activeFilter.to_json)
			end
			if params['search']['filter_longitude'].to_s.strip.length != 0
						mapFilter = {"geo_distance"=>{ "distance" => params['search']['filter_distance'] +"km" , "stream.location" => { "lat" => params['search']['filter_latitude'] , "lon" => params['search']['filter_longitude'] }}}
						filters.push(mapFilter.to_json)
			end
			#A quick way to check if filter is nil or empty or just whitespace
			if filters.empty?
				body = '{ "sort": ['+ sort_by + '],
					"query" : {"query_string" : {"query" : "' + params['search']['query'] + '"}}
					}'
			else
				body = '{ "sort": ['+ sort_by + '],
								"query": {
									"filtered": {
										"query" : {"query_string" : {"query" : "' + params['search']['query'] + '"}},
										"filter":{
											"and": ['+ filters.join(",") + ']
										}
									}
								}
							}'
			end
			logger.debug "*** url: #{url} ***"
			logger.debug "*** body: #{body} ***"
			res = Api.post(url, JSON.parse(body))

			json = res["body"]
			@streams = json['streams']['hits']['hits']
			@users = json['users']['hits']['hits']
			@count_streams = json['streams']['hits']['total']
			@count_users = json['users']['hits']['total']
			@count_all = json['streams']['hits']['total'] + json['users']['hits']['total']
			@nb_pages = (@count_streams / @nb_results_per_page).ceil
			@nb_pages_users = (@count_users / @nb_results_per_page).ceil
			@query = params['search']['query']
			unless params['search']['page'].blank?
				@current_page = params['search']['page'].to_i
			else
				@current_page = -1
			end
			unless params['search']['page_users'].blank?
				@current_page_users = params['search']['page_users'].to_i
			else
				@current_page_users = -1
			end
			logger.debug "CURRENT_PAGE: #{@current_page}"
			logger.debug "CURRENT_PAGE_USERS: #{@current_page_users}"

      if params['search']['refresh'] == "false"
        if (not params['search']['page'].blank?)
          @type = "stream"
          @stream_page_number = (params['search']['page'].to_i)*@nb_results_per_page;
        else
          @type = "user"
        end
        respond_to do |format|
          format.js
        end
      else
        render :action => 'show'        
      end
		end
	end
end
