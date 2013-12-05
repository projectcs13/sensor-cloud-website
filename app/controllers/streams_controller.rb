class StreamsController < ApplicationController

	before_action :correct_user,   only: [:edit, :update, :destroy]
  # before_action :get_user_id,    only: [:post, :put, :multipost, :deleteAll, :new_connection]
  before_action :set_stream,     only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user, only: [:index, :edit, :update, :destroy]

  def index

    # @streams = Stream.search(params[:search])
    # @streams = Stream.all(_user_id: current_user.username)
    # @count= @streams.count
    #Before MERGING User Profile branch
    # cid = @user.username
    @cid = User.find_by_username(:username)
    logger.debug "CURRENT_PAGE: ##{CONF['API_URL']}/users/#{params[:username]}/streams/"
    res = Faraday.get "#{CONF['API_URL']}/users/#{params[:username]}/streams/"
    @streams = JSON.parse(res.body)['streams']
    @count= @streams.length
    logger.debug "CURRENT_PAGE: #{@streams}"
  end

  def show
		@stream_id = params[:id]
		resp = Faraday.get "#{CONF['API_URL']}/streams/#{@stream_id}"
		stream_owner_id = JSON.parse(resp.body)['user_id']
		@stream_owner = User.find_by_username(stream_owner_id)
    @usern = @stream_owner.username
    logger.debug "Owner: #{@usern}"
  end

  def new
    @stream = Stream.new
  end

  def new_from_resource
    @stream = Stream.new
    @stream.id = "REPLACE_THIS_ID"
  end

  def multi
    @streams = []
    params[:multistream].each do |k, v|
      @stream = Stream.build v
      #@stream.user_id = current_user.id.to_s
      correctBooleanFields
      @streams.push @stream
    end

    res = multipost
    sleep 1.0
    location = { :url => "#{streams_path}" }
    respond_to do |format|
      format.json { render json: location, status: res.status }
    end
  end

  def make_suggestion_by model
    res = Faraday.get "#{CONF['API_URL']}/suggest/#{model}?size=10"
    logger.debug JSON.parse(res.body)
    if res.status == 404
      data = {}
    else
      data = JSON.parse(res.body)['suggestions']
    end

    data
  end

  def suggest
    sug = make_suggestion_by params[:model]
    status = if sug then 200 else 404 end
    logger.debug sug
    render :json => sug, :status => status
  end

  def fetchResource
    res = Faraday.get "#{CONF['API_URL']}/resources/#{params[:id]}"
    render :json => res.body, :status => res.status
  end

  def smartnew
  end

  

  def correctBooleanFields
    @stream.location = "#{@stream.latitude},#{@stream.longitude}"
    @stream.attributes.delete 'longitude'
    @stream.attributes.delete 'latitude'

    # Remove attributes when editing a stream
    @stream.attributes.delete 'active'
    @stream.attributes.delete 'user_ranking'
    @stream.attributes.delete 'last_updated'
    @stream.attributes.delete 'history_size'
    @stream.attributes.delete 'creation_date'
    @stream.attributes.delete 'quality'
    @stream.attributes.delete 'subscribers'


    @stream.polling = if @stream.polling == "1" then false else true end
    @stream.private = if @stream.private == "0" then false else true end

    if @stream.accuracy     == ""  then @stream.accuracy     = nil end
    if @stream.min_val      == ""  then @stream.min_val      = nil end
    if @stream.max_val      == ""  then @stream.max_val      = nil end
    if @stream.polling_freq == ""  then @stream.polling_freq = nil end
    if @stream.location     == "," then @stream.location     = nil end

    @stream.polling_freq = @stream.polling_freq.to_i
  end

  def create
    @stream = Stream.new(stream_params)
    correctBooleanFields

    logger.debug "attributes"
    logger.debug @stream.attributes

    respond_to do |format|
      res = post
        logger.debug "BODY: #{res.body}"
        if res.status == 200

          @stream.id = JSON.parse(res.body)['_id']
          # TODO
          # The API is currently sending back the response before the database has
  				# been updated. The line below will be removed once this bug is fixed.
        	sleep(1.0)

  				format.html { redirect_to stream_path(@stream.id) }
        	format.json { render json: {"id" => @stream.id}, status: res.status }
      	else
        	format.html { render action: 'new' }
        	format.json { render json: {"error" => @stream.errors}, status: :unprocessable_entity }
      	end
    end
  end

  def update
    @stream.assign_attributes(stream_params)
    correctBooleanFields

    respond_to do |format|
      res = put
      logger.debug "attributes: #{@stream.attributes}"
      res.on_complete do
        if res.status == 200
          # TODO
          # The API is currently sending back the response before the database has
          # been updated. The line below will be removed once this bug is fixed.
          sleep(1.0)

          format.html { redirect_to stream_path(@stream.id) }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @stream.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @stream.destroy
    Relationship.all.where(followed_id: @stream.id).each do |r|
      r.destroy
    end

    # TODO
    # The API is currently sending back the response before the database has
    # been updated. The line below will be removed once this bug is fixed.
    sleep(1.0)

    respond_to do |format|
      format.html { redirect_to streams_path }
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
      format.html { redirect_to streams_path }
      format.json { head :no_content }
    end
  end


  def fetch_datapoints
    res = Faraday.get "#{CONF['API_URL']}/streams/" + params[:id] + "/data/_search"
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  def fetch_prediction
    res = Faraday.get "#{CONF['API_URL']}/streams/" + params[:id] + "/_analyse"
    logger.debug "RES: #{res.body}"
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  

  def post
    cid = current_user.username
    url = "#{CONF['API_URL']}/users/#{cid}/streams/"
    send_data(:post, url, @stream.attributes.to_json)
  end

  def multipost
    cid = current_user.id
    url = "#{CONF['API_URL']}/users/#{cid}/streams/"

    arr = []
    @streams.each do |stream|
      arr.push stream.attributes
    end
    req = { :multi_json => arr }.to_json
    logger.debug "REQ: #{req}"

    send_data(:post, url, req)
  end

  def put
    cid = current_user.username
    url = "#{CONF['API_URL']}/users/#{cid}/streams/#{@stream.id}"
    @stream.attributes.delete 'id'
    send_data(:put, url, @stream.attributes.to_json)
  end

  private

  
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      #@stream = Stream.find(params[:id], _user_id: current_user.id)
      @stream = Stream.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :longitude, :latitude, :polling, :uri, :polling_freq, :data_type, :parser)
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

    def deleteAll
    cid = current_user.username
    url = "#{CONF['API_URL']}/users/#{cid}/streams/"
    send_data(:delete, url, nil)
    end

    def edit
    logger.debug "#{@stream.attributes}"

    if @stream.accuracy      == nil then @stream.accuracy     = "" end
    if @stream.min_val       == nil then @stream.min_val      = "" end
    if @stream.max_val       == nil then @stream.max_val      = "" end
    if @stream.polling_freq  == nil then @stream.polling_freq = "" end
    if @stream.location      == nil then @stream.location     = "," end

    logger.debug "#{@stream.attributes}"

    location = @stream.location.split(",", 2)

    @stream.send("latitude=", location[0])
    @stream.send("longitude=", location[1])
  end

    def new_connection
      cid = current_user.username
      @conn = Faraday.new(:url => "#{CONF['API_URL']}/users/#{cid}/") do |faraday|
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
      stream = Stream.find(params[:id])
			@user = User.find_by_username(stream.user_id)
			redirect_to(root_url) unless current_user?(@user)
		end
end
