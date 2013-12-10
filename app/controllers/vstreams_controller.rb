class VstreamsController < ApplicationController

  before_action :correct_user,   only: [:edit, :update, :destroy]
  # before_action :get_user_id,    only: [:post, :put, :multipost, :deleteAll, :new_connection]
  before_action :set_vstream,     only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]

  def index
    # @streams = Stream.search(params[:search])
    # @streams = Stream.all(_user_id: current_user.username)
    # @count= @streams.count
    #Befor MERGING User Profile branch
    cid = current_user.username
    res = Faraday.get "#{CONF['API_URL']}/vstreams/"
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

  def new_vstream
    @vstream = Vstream.new
    respond_to do |format|
      format.html
      format.js
    end
  end

  def edit
    logger.debug "#{@vstream.attributes}"

    if @vstream.accuracy      == nil then @vstream.accuracy     = "" end
    if @vstream.min_val       == nil then @vstream.min_val      = "" end
    if @vstream.max_val       == nil then @vstream.max_val      = "" end
    if @vstream.polling_freq  == nil then @vstream.polling_freq = "" end
    if @vstream.location      == nil then @vstream.location     = "," end

    logger.debug "#{@vstream.attributes}"

    location = @vstream.location.split(",", 2)

    @vstream.send("latitude=", location[0])
    @vstream.send("longitude=", location[1])
  end

  def correctBooleanFields
    @vstream.location = "#{@vstream.latitude},#{@vstream.longitude}"
    @vstream.attributes.delete 'longitude'
    @vstream.attributes.delete 'latitude'

    # Remove attributes when editing a vstream
    @vstream.attributes.delete 'active'
    @vstream.attributes.delete 'user_ranking'
    @vstream.attributes.delete 'last_updated'
    @vstream.attributes.delete 'history_size'
    @vstream.attributes.delete 'creation_date'
    @vstream.attributes.delete 'quality'
    @vstream.attributes.delete 'subscribers'

    @vstream.polling = if @vstream.polling == "1" then false   else true   end
    @vstream.private = if @vstream.private == "0" then "false" else "true" end

    if @vstream.accuracy     == ""  then @vstream.accuracy     = nil end
    if @vstream.min_val      == ""  then @vstream.min_val      = nil end
    if @vstream.max_val      == ""  then @vstream.max_val      = nil end
    if @vstream.polling_freq == ""  then @vstream.polling_freq = nil end
    if @vstream.location     == "," then @vstream.location     = nil end

    @vstream.polling_freq = @vstream.polling_freq.to_i
  end

  def create
    @vstream = Vstream.new(vstream_params)
    correctBooleanFields

    logger.debug "attributes"
    logger.debug @vstream.attributes

    respond_to do |format|
    	res = post
        logger.debug "BODY: #{res.body}"
      	if res.status == 200

          @vstream.id = JSON.parse(res.body)['_id']
  				# TODO
          # The API is currently sending back the response before the database has
  				# been updated. The line below will be removed once this bug is fixed.
        	sleep(1.0)

  				format.html { redirect_to vstream_path(@vstream.id) }
        	format.json { render action: 'show', status: :created, location: @vstream }
      	else
        	format.html { render action: 'new' }
        	format.json { render json: @vstream.errors, status: :unprocessable_entity }
      	end
    end
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
    @vstream.destroy
		Relationship.all.where(followed_id: @vstream.id).each do |r|
			r.destroy
		end

    # TODO
    # The API is currently sending back the response before the database has
    # been updated. The line below will be removed once this bug is fixed.
		sleep(1.0)

    respond_to do |format|
      format.html { redirect_to vstreams_path }
      format.json { head :no_content }
    end
  end

  def destroyAll
    deleteAll
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
  logger.debug "PARAMS: #{params}"
  logger.debug '{"user_id" : "#{current_user.username}", "name" : "'+params[:name]+'", "description" :  "'+params[:description]+'", "streams_involved" : '+params[:streams_involved]+', "timestampfrom" : "now-1w", "function" : ' + params[:function] + '}'

  conn = Faraday.new(:url => "#{CONF['API_URL']}/vstreams/") do |faraday|
    faraday.request  :url_encoded               # form-encode POST params
    faraday.response :logger                    # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter    # make requests with Net::HTTP
  end


  res = conn.post do |req|
    req.url "#{CONF['API_URL']}/vstreams/"
    req.headers['Content-Type'] = 'application/json'
    req.body = '{"user_id" : "sookie2", "name" : "'+params[:name]+'", "description" :  "'+params[:description]+'", "streams_involved" : '+params[:streams_involved]+', "timestampfrom" : "now-1w", "function" : ' + params[:function] + '}'
  end


  respond_to do |format|
    json = JSON.parse(res.body)
    id = json["_id"]
    format.html { redirect_to "/vstreams/#{id}" }
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
    cid = current_user.username
    url = "#{CONF['API_URL']}/users/#{cid}/vstreams/"
    send_data(:delete, url, nil)
  end

  def post
    cid = current_user.username
    url = "#{CONF['API_URL']}/vstreams/"
    send_data(:post, url, @vstream.attributes.to_json)
  end

  def multipost
    cid = current_user.id
    url = "#{CONF['API_URL']}/users/#{cid}/vstreams/"

    arr = []
    @vstreams.each do |vstream|
      arr.push vstream.attributes
    end
    req = { :multi_json => arr }.to_json
    logger.debug "REQ: #{req}"

    send_data(:post, url, req)
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
      #@vstream = vstream.find(params[:id], _user_id: current_user.id)
      @vstream = Vstream.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def vstream_params
      params.require(:vstream).permit(:name, :description, :function)
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
			@user = User.find(Vstream.find(params[:id]).user_id)
			redirect_to(root_url) unless current_user?(@user)
		end
end