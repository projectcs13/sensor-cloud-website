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
    logger.debug "DEEEEEEBUGGG!!:: #{params}"
		@nb_results_per_page = 20
		@query = params['search']['query']
		query_from = if params['search']['page'].blank? then 0 else (params['search']['page'].to_i * @nb_results_per_page).to_i end
		sort_by = if params['search']['sort_by'] == "none" then
						     {}
				       elsif params['search']['sort_by'].nil?
				         { "average" => "desc" }
			         else
				         { "#{params['search']['sort_by']}" => "desc" }
			         end
    url = "/_search?location=true&from=#{query_from}&size=#{@nb_results_per_page.to_i}"
    tags = params['search']['filter_tag'].split(",") unless params['search']['filter_tag'].nil? or params['search']['filter_tag'].blank?
    filters = Array.new
    filters.push({ "regexp" => { "unit" => { "value" => params['search']['filter_unit'] } } }) unless params['search']['filter_unit'].nil? or params['search']['filter_unit'].blank?
    filters.push({ "regexp" => { "active" => { "value" => params['search']['active'] } } }) unless params['search']['filter_active'] == "any" or params['search']['filter_active'].blank?
    filters.push({ "terms" => { "tags" =>  tags } }) unless tags.nil? 
    filters.push({ "geo_distance" => { "distance" => params['search']['filter_distance'] + "km" , "stream.location" => { "lat" => params['search']['filter_latitude'] , "lon" => params['search']['filter_longitude'] } } }) unless params['search']['filter_longitude'].nil? or params['search']['filter_longitude'].blank? 
	
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
											"and" => filters
										}
									}
								}
							}
		end
      logger.debug "DEEEEEEBUGGG!!:: #{body}"
			res = Api.post(url, body)

			@streams = res["body"]['streams']['hits']['hits']
			@users = res["body"]['users']['hits']['hits']
			@count_streams = res["body"]['streams']['hits']['total']
			@count_users = res["body"]['users']['hits']['total']
			@count_all = @count_streams + @count_users
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
