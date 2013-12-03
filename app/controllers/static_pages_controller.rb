class StaticPagesController < ApplicationController
  def home
  	@home_page = true

  	logger.debug "hello"

  	conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
			faraday.request  :url_encoded             # form-encode POST params
			faraday.response :logger                  # log requests to STDOUT
			faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
		end

		res = conn.post do |req|
			req.url "/_search?from=0&size=10"
			req.headers['Content-Type'] = 'application/json'
			sort_by = '{"user_ranking.average":"desc" }'
			req.body = '{"sort":{"user_ranking.average":"desc"}, "query":{"match_all":{}}}'
		
		end


		#logger.debug "#{res.body}"
		json = JSON.parse(res.body)
		@streams = json['streams']['hits']['hits']

		q = "stream_id="
		@streams.each do |stream|
			#logger.debug "#{stream['_id']}"
			q = q + "," + "#{stream['_id']}"
		end

		#logger.debug "#{q}"
		res = conn.get do |req|
			req.url "/_history?" + q + "&size=1"
			req.headers['Content-Type'] = 'application/json'
		end

		#logger.debug "#{res.body}"
		json = JSON.parse(res.body)
		@values_ = json['history']
		logger.debug "#{@values}"

		@values = Hash.new("NO DATA")
		@values_.each do |val|
			if val['data'] != []
				logger.debug "#{val['data'][0]['value']}"
				@values["#{val['stream_id']}"] = val['data'][0]['value']
			end
		end


		#@users = json['users']['hits']['hits']
		#@count_streams = json['streams']['hits']['total']
		#@count_users = json['users']['hits']['total']
		#@count_all = json['streams']['hits']['total'] + json['users']['hits']['total']
		#@nb_pages = (@count_streams / @nb_results_per_page).ceil
		#@nb_pages_users = (@count_users / @nb_results_per_page).ceil
		#@query = params['search']['query']

		
  end

  def help
  end

  def about
  end

  def faq
  end

  def manual
  end

  def privacy
  end

  def api
  end

  def security
  end

  def terms
  end
end
