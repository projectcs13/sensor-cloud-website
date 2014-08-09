class VstreamsController < ApplicationController

  before_action :correct_user,   only: [:edit, :update, :destroy]
  before_action :set_vstream,     only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]

  def index
    cid = current_user.username
    res = Api.get "/users/#{params[:user_id]}/vstreams", openid_metadata
    check_new_token res
    @vstreams = res['body']['vstreams']
    @count = @vstreams.length
  end

  def show
		res = Api.get "/users/#{params[:user_id]}/vstreams/#{params[:id]}", openid_metadata
    check_new_token res
		vstream_owner_id = res['body']['user_id']
		@vstream_owner = User.find_by(username: vstream_owner_id)
    @triggers = nil

    if signed_in? and current_user.username == @vstream_owner.username then
      response = Api.get "/users/#{@vstream_owner.username}/vstreams/#{params[:id]}/triggers", openid_metadata
      check_new_token response
      @triggers = response['body']['triggers']
    end
    @functions = {"greater_than" => "Greater than", "less_than" => "Less than", "span" => "Span"}
  end


  def edit
  end

  def create
  end

  def update
    @vstream.assign_attributes(vstream_params)
    @vstream.attributes.delete 'streams_involved'
    @vstream.attributes.delete 'starting_date'
    @vstream.attributes.delete 'function'
    @vstream.attributes.delete 'id'
    @vstream.attributes.delete 'creation_date'
    @vstream.attributes.delete 'history_size'
    @vstream.attributes.delete 'last_updated'
    @vstream.attributes.delete 'timestampfrom'



    respond_to do |format|
      vstream_id = params[:id]
      logger.debug "these are the parameters #{@vstream.attributes}"
      res = Api.put "/vstreams/#{vstream_id}", @vstream.attributes, openid_metadata
      check_new_token res
      res["response"].on_complete do
        if res["status"] == 200 and @vstream.valid?
          # TODO
          # The API is currently sending back the response before the database has
          # been updated. The line below will be removed once this bug is fixed.
          sleep(1.0)

          format.html { redirect_to user_vstream_path(current_user,vstream_id) }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @vstream.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @user = current_user
    @vstream.destroy

    # TODO
    # The API is currently sending back the response before the database has
    # been updated. The line below will be removed once this bug is fixed.
		sleep(1.0)

    respond_to do |format|
      format.html { redirect_to "/users/#{current_user.username}/vstreams" }
      format.json { head :no_content }
    end
  end

  def destroyAll
    @user = current_user
    res = deleteAll

    # TODO
    # The API is currently sending back the response before the database has
    # been updated. The line below will be removed once this bug is fixed.
    sleep(1.0)

    respond_to do |format|
      format.html { redirect_to vstreams_path }
      format.json { head :no_content }
    end
  end

  def create2
    req_body = { "tags"             => params[:tags],
                 "user_id"          => params[:user_id],
                 "name"             => params[:name],
                 "description"      => params[:description],
                 "streams_involved" => JSON.parse(params[:streams_involved]),
                 "timestampfrom"    => params[:starting_date],
                 "function"         => JSON.parse(params[:function]) }

    res = Api.post "/vstreams", req_body, openid_metadata
    check_new_token res

    respond_to do |format|
      json = res['body']
      id = json["_id"]
      user_id = json["user_id"]
      format.html { redirect_to "/users/#{params[:user_id]}/vstreams/#{id}" }
    end
  end

  def fetch_datapoints
    res = Api.get "/vstreams/#{params[:id]}/data/_search", openid_metadata
    check_new_token res
    respond_to do |format|
      format.json { render json: res['body'], status: res['status'] }
    end
  end

  def fetch_prediction
    res = Api.get "/vstreams/#{params[:id]}/_analyse?nr_values=#{params[:in]}&nr_preds=#{params[:out]}", openid_metadata
    check_new_token res
    respond_to do |format|
      format.js { render "fetch_prediction", :locals => {:data => res["body"].to_json} }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vstream
      @vstream = Vstream.find(params[:id], user_id: params[:user_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vstream_params
      params.require(:vstream).permit(:name, :description, :function, :tags)
    end

		# Before filters
		def signed_in_user
			unless signed_in?
				store_location
				flash[:warning] = "Please sign in"
				redirect_to signin_url
			end
		end

    def correct_user
      res = Api.get "/vstreams/#{params[:id]}", openid_metadata
      check_new_token res
      @stream_owner_id = res['body']['user_id']
      @user = User.find_by_username(@stream_owner_id)
      redirect_to(root_url) unless current_user?(@user)
    end
end
