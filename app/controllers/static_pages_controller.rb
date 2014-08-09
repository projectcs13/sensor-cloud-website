class StaticPagesController < ApplicationController

  def home
  	@home_page = true

    sort = { "user_ranking.average" => "desc" }
    query = { match_all: {} }

    res = Api.post "/_search?from=0&size=10", {sort: sort, query: query}, FRONTEND_TOKEN
    check_new_token_frontend res

    @streams = res["body"]["streams"]["hits"]["hits"]
    @streams = []

    q = "stream_id="
    @streams.each do |stream| q = q + "," + "#{stream['_id']}" end

		res = Api.get "/_history?#{q}&size=1", FRONTEND_TOKEN
    check_new_token_frontend res

		@values_ = res["body"]["history"]
    @values_ = []

		@values = Hash.new("NO DATA")
		@values_.each do |val|
			if val['data'] != []
				@values["#{val['stream_id']}"] = val['data'][0]['value']
			end
		end
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

  private

    def check_new_token_frontend res
      new_access_token = res["body"]["new_access_token"]
      if new_access_token                                # If there's a new access token, keep it
        FRONTEND_TOKEN[:access_token] = new_access_token
        user = User.find_by_username FRONTEND_TOKEN[:username]
        user.save if user.update_attributes access_token: new_access_token
      end
    end

end
