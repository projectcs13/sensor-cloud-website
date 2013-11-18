class SearchesController < ApplicationController

  def show
  end

	def create
		@nb_results_per_page = 5.0
		if params['search']['query'].blank?
			redirect_to root_path
		else
      conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
      	faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      res = conn.post do |req|
				unless params['search']['page'].blank?
					req.url "/_search?from=#{(params['search']['page'].to_i)*(@nb_results_per_page.to_i)}&size=#{@nb_results_per_page.to_i}"
				else

        req.url "/_search?from=0&size=#{@nb_results_per_page.to_i}"
				end
        req.headers['Content-Type'] = 'application/json'

        if params['search']['sort_by'].nil? 
          sort_by = '{}' 
        else 
          sort_by = '{"' + params['search']['sort_by'] + '":"asc" }'
        end
   
        #req.body = '{"query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}}}'
        #A quick way to check if filter is nil or empty or just whitespace
    	filters = Array.new
    	if params['search']['filter_name'] == "1"
     		nameFilter = {"regexp"=>{ "name" => { "value" => ".*" + params['search']['filter'] + ".*"}}} 
     		filters.push(nameFilter.to_json)
       	end
     	if params['search']['filter_tag'] == "1"
     	    tagFilter = {"regexp"=>{ "tags" => { "value" => ".*" + params['search']['filter'] + ".*"}}} 
     	    filters.push(tagFilter.to_json)
      	end
      	if params['search']['filter'].to_s.strip.length == 0 || filters.empty?
      		req.body = '{ "sort": ['+ sort_by + '],
            "query" : {"query_string" : {"query" : "' + params['search']['query'] + '"}}
            }'
      	else
      	req.body = '{ "sort": ['+ sort_by + '],
                  "query": {
                    "filtered": {
                      "query" : {"query_string" : {"query" : "' + params['search']['query'] + '"}},
                      "filter":{
                        "or": ['+ filters.join(",") + ']
                      }
                    }
                  }
                }'
      end
        	logger.debug "#{req.body}"

      end
			logger.debug "#{res.body}"
      json = JSON.parse(res.body)
      @streams = json['streams']['hits']['hits']
      @users = json['users']['hits']['hits']
      @count_streams = json['streams']['hits']['total']
      @count_users = json['users']['hits']['total']
      @count_all = json['streams']['hits']['total'] + json['users']['hits']['total']
			@nb_pages = (@count_all / @nb_results_per_page).ceil 
			@query = params['search']['query']
			unless params['search']['page'].blank?
				@current_page = params['search']['page'].to_i
			else
				@current_page = 1
			end
			logger.debug "CURRENT_PAGE: #{@current_page}"
			render :action => 'show'
		end
	end
end
