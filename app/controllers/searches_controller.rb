class SearchesController < ApplicationController

  def show
  end

	def create
		if params['search']['query'].blank?
			redirect_to root_path
		else
      conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
      	faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end

      res = conn.post do |req|
        req.url '/_search'
        req.headers['Content-Type'] = 'application/json'

        if params['search']['sort_by'].nil? 
          sort_by = '{}' 
        else 
          sort_by = '{"' + params['search']['sort_by'] + '":"asc" }'
        end
   
        #req.body = '{"query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}}}'
  
  	filters = Array.new
    	if params['search']['filter_name'].to_s.strip.length != 0
     		nameFilter = {"regexp"=>{ "name" => { "value" => ".*" + params['search']['filter_name'] + ".*"}}} 
     		filters.push(nameFilter.to_json)
       	end
     	if params['search']['filter_tag'].to_s.strip.length != 0
     	    tagFilter = {"regexp"=>{ "tags" => { "value" => ".*" + params['search']['filter_tag'] + ".*"}}} 
     	    filters.push(tagFilter.to_json)
      end
      if params['search']['filter_rank'] == "1"
          rankFilter = {"range"=>{ "user_ranking" => {"gte" => params['search']['min_val'] , "lte" => params['search']['max_val']}}}
          filters.push(rankFilter.to_json)
      end
        #A quick way to check if filter is nil or empty or just whitespace
      	if filters.empty?
      		req.body = '{ "sort": ['+ sort_by + '],
            "query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}}
            }'
      	else
      	req.body = '{ "sort": ['+ sort_by + '],
                  "query": {
                    "filtered": {
                      "query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}},
                      "filter":{
                        "and": ['+ filters.join(",") + ']
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
			@query = params['search']['query']

			render :action => 'show'
		end
	end
end
