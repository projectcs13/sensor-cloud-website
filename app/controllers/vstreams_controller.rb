class VstreamsController < ApplicationController

  before_action :correct_user,   only: [:edit, :update, :destroy]
  # before_action :get_user_id,    only: [:post, :put, :multipost, :deleteAll, :new_connection]
  before_action :set_vstream,     only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]

  def index
    cid = current_user.username
    res = Faraday.get "#{CONF['API_URL']}/users/#{params[:user_id]}/vstreams/"
    @vstreams = JSON.parse(res.body)['users']
    @count= @vstreams.length
    logger.debug "CURRENT_PAGE: #{@vstreams}"
  end

  def show
		@vstream_id = params[:id]
		resp = Faraday.get "#{CONF['API_URL']}/vstreams/#{@vstream_id}"
		vstream_owner_id = JSON.parse(resp.body)['user_id']
		@vstream_owner = User.find_by(id: vstream_owner_id)
  end


  def edit

  end

  def correctBooleanFields

    @vstream.private = if @vstream.private == "0" then "false" else "true" end

  end

  def create
    
  end

  def update
    @vstream.assign_attributes(vstream_params)
    correctBooleanFields

    respond_to do |format|
    	res = put
      logger.debug "attributes: #{@vstream.attributes}"
    	res.on_complete do
      	if res.status == 200
          # TODO
          # The API is currently sending back the response before the database has
          # been updated. The line below will be removed once this bug is fixed.
					sleep(1.0)

        	format.html { redirect_to vstream_path(@vstream.id) }
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
    #@stream.destroy(_user_id: current_user.username)
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
  conn = Faraday.new(:url => "#{CONF['API_URL']}/vstreams/") do |faraday|
    faraday.request  :url_encoded               # form-encode POST params
    faraday.response :logger                    # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter    # make requests with Net::HTTP
  end


  res = conn.post do |req|
    req.url "#{CONF['API_URL']}/vstreams/"
    req.headers['Content-Type'] = 'application/json'
    req.body = '{"tags" : "'+params[:tags]+'", "user_id" : "'+params[:user_id]+'", "name" : "'+params[:name]+'", "description" :  "'+params[:description]+'", "streams_involved" : '+params[:streams_involved]+', "timestampfrom" : "'+params[:starting_date]+'", "function" : ' + params[:function] + '}'
  end


  respond_to do |format|
    json = JSON.parse(res.body)
    id = json["_id"]
    user_id= json["user_id"]
    format.html { redirect_to "/users/"+params[:user_id]+"/vstreams/#{id}" }
    #render :action => 'show', :id => json["_id"]
  end

end


  def fetch_datapoints
    res = Faraday.get "#{CONF['API_URL']}/vstreams/" + params[:id] + "/data/_search"
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  def fetch_prediction
    res = Faraday.get "#{CONF['API_URL']}/vstreams/" + params[:id] + "/_analyse"
    logger.debug "RES: #{res.body}"
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  def deleteAll
    cid = @user.username
    url = "#{CONF['API_URL']}/users/#{cid}/vstreams/"
    send_data(:delete, url, nil)
  end

  def post
    cid = current_user.username
    url = "#{CONF['API_URL']}/vstreams/"
    send_data(:post, url, @vstream.attributes.to_json)
  end

  def put
    cid = current_user.username
    url = "#{CONF['API_URL']}/users/#{cid}/vstreams/#{@vstream.id}"
    @vstream.attributes.delete 'id'
    send_data(:put, url, @vstream.attributes.to_json)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_vstream
      @vstream = Vstream.find(params[:id], user_id: params[:user_id])
      #@vstream = Vstream.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vstream_params
      params.require(:vstream).permit(:name, :description, :function, :tags)
    end

    # def load_parent
    #   @user = User.find(current_user.username)
    # end

    def send_data(method, url, json)
      new_connection unless @conn
      @conn.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = json
      end
    end

    def new_connection
      cid = current_user.username
      @conn = Faraday.new(:url => "#{CONF['API_URL']}/vstreams") do |faraday|
        faraday.request  :url_encoded               # form-encode POST params
        faraday.response :logger                    # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter    # make requests with Net::HTTP
      end
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
      resp = Faraday.get "#{CONF['API_URL']}/vstreams/#{params[:id]}"
      @stream_owner_id = JSON.parse(resp.body)['user_id']
      # stream = Stream.find(_user_id: params[:id])
      @user = User.find_by_username(@stream_owner_id)
      redirect_to(root_url) unless current_user?(@user)

    end
end