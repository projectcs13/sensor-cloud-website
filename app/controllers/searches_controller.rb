class SearchesController < ApplicationController

  def show
  end

	def create
		if params['search']['query'] == ''
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
        #req.body = '{"query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}}}'
	if params['search']['sort_by'].nil?
        	req.body = '{"sort": [{}], "query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}}}'
        	logger.debug "#{req.body}"
	else
		req.body = '{"sort": [{"' + params['search']['sort_by'] + '":"asc"}], "query" : {"query_string" : { "query" : "' + params['search']['query'] + '"}}}'
        	logger.debug "#{req.body}"
	end
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
