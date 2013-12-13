class SearchesController < ApplicationController
	def new
        @vstream = Vstream.new

    end
	
    def index
    	@vstream = Vstream.new
    end	


	def show
		@vstream = Vstream.new
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
		@vstream = Vstream.new
		@nb_results_per_page = 8.0
		if params['search']['query'].blank?
			redirect_to root_path
		else
			query_from = if params['search']['page'].blank? then 0 else (params['search']['page'].to_i * @nb_results_per_page).to_i end
			url = "/_search?location=false&from=#{query_from}&size=#{@nb_results_per_page.to_i}"


			if params['search']['sort_by'] == "none"
				sort_by = {}
			elsif params['search']['sort_by'].nil?
				sort_by = { "average" => "desc" }
			else
				sort_by = { "#{params['search']['sort_by']}" => "desc" }
			end

			filters = Array.new
			if params['search']['filter_unit'].to_s.strip.length != 0
				nameFilter = { "regexp" => { "unit" => { "value" => params['search']['filter_unit'] } } }
				filters.push(nameFilter.to_json)
			end
			if params['search']['filter_tag'].to_s.strip.length != 0
				tagFilter = { "regexp" => { "tags" => { "value" => params['search']['filter_tag'] } } }
				filters.push(tagFilter.to_json)
			end
			if params['search']['filter_rank'] == "1"
				rankFilter = {"range" => { "user_ranking.average" => { "gte" => params['search']['min_val'], "lte" => params['search']['max_val'] } } }
				filters.push(rankFilter.to_json)
			end
			if params['search']['filter_active'] == "1"
				activeFilter = { "regexp" => { "active" => { "value" => params['search']['active'] } } }
				filters.push(activeFilter.to_json)
			end
			if params['search']['filter_longitude'].to_s.strip.length != 0
				mapFilter = { "geo_distance" => { "distance" => params['search']['filter_distance'] + "km" , "stream.location" => { "lat" => params['search']['filter_latitude'] , "lon" => params['search']['filter_longitude'] } } }
				filters.push(mapFilter.to_json)
			end
			#A quick way to check if filter is nil or empty or just whitespace
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
												"and" => ['+ filters.join(",") + ']
											}
										}
									}
								}
			end

			res = Api.post(url, body)

			@vstreams = res["body"]['vstreams']['hits']['hits']
			@streams = res["body"]['streams']['hits']['hits']
			@users = res["body"]['users']['hits']['hits']
			@count_streams = res["body"]['streams']['hits']['total']
			@count_vstreams = res["body"]['vstreams']['hits']['total']
			@count_users = res["body"]['users']['hits']['total']
			@count_all = @count_streams + @count_users + @count_vstreams
			
			@query = params['search']['query']

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
