class SearchController < ApplicationController

  # GET /search
  # GET /search.json
  def index
    logger.debug "Query: #{params}"

    ##changed by lihao
    if params['search'] == ''
      print 'the search input should not be empty! '
      redirect_to '/'
    else

      conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
          faraday.request  :url_encoded             # form-encode POST params
          faraday.response :logger                  # log requests to STDOUT
          faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
      res = conn.post do |req|
        # req.url '/_search?from=0&size=20'
        req.url '/_search'
        req.headers['Content-Type'] = 'application/json'
        req.body = '{"query" : {"query_string" : { "query" : "' + params['search'] + '"}}}'
        logger.debug "#{req.body}"
      end
      logger.debug "#{res.body}"
      json = JSON.parse(res.body)
      @streams = json['streams']['hits']['hits']
      @users = json['users']['hits']['hits']
      @count_streams = json['streams']['hits']['total']
      @count_users = json['users']['hits']['total']
      @count_all = json['streams']['hits']['total'] + json['users']['hits']['total']
    end
    ##end of changes

  end
end
