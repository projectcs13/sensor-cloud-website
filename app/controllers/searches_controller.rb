class SearchesController < ApplicationController

  def index
    logger.debug "Query: #{params}"

    if params['searches'] == ''
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
        req.body = '{"query" : {"query_string" : { "query" : "' + params['searches'] + '"}}}'
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
  end
end
