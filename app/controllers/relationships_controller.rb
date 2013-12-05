class RelationshipsController < ApplicationController
	#before_action :signed_in_user

	def create
		@stream_id = params[:relationship][:followed_id]
		#current_user.follow!(@stream_id)

		conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
		  faraday.request  :url_encoded             # form-encode POST params
		  faraday.response :logger                  # log requests to STDOUT
		  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
		end

		resp = conn.put do |req|
		  req.url "/users/#{current_user.username}/_subscribe"
		  req.headers['Content-Type'] = 'application/json'
		  req.body = "{\"stream_id\":\"#{@stream_id}\"}"
		  logger.debug "*** req.body: #{req.body} ***"
		end

		respond_to do |format|
			format.html { redirect_to root_path }
			format.js
		end
	end

	def destroy
		#@stream_id = Relationship.find(params[:id]).followed_id
		@stream_id = "gpWYUW4JQ7-93d8Z5A3-6w"
		#current_user.unfollow!(@stream_id)

		conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
		  faraday.request  :url_encoded             # form-encode POST params
		  faraday.response :logger                  # log requests to STDOUT
		  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
		end

		resp = conn.put do |req|
		  req.url "/users/#{current_user.username}/_unsubscribe"
		  req.headers['Content-Type'] = 'application/json'
		  req.body = "{\"stream_id\":\"#{@stream_id}\"}"
		  logger.debug "*** req.body: #{req.body} ***"
		end

		respond_to do |format|
			format.html { redirect_to root_path }
			format.js
		end
	end
end
