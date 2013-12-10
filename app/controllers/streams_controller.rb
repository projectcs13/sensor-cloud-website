class StreamsController < ApplicationController

  before_action :get_current_user, only: [:index, :show, :new, :create, :update, :destroy, :destroyAll, :post, :put, :deleteAll]
  before_action :correct_user,     only: [:edit, :update, :destroy]
  before_action :set_stream,       only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user,   only: [:index, :edit, :update, :destroy]

  def index
    response = Faraday.get "#{CONF['API_URL']}/users/#{@user.username}/streams"
    @streams = JSON.parse(response.body)['streams']
  end

  def show
		@stream_id = params[:id]
		resp = Faraday.get "#{CONF['API_URL']}/streams/#{@stream_id}"
		stream_owner_id = JSON.parse(resp.body)['user_id']
		@stream_owner = User.find_by(username: stream_owner_id)
  end

  def new
    @stream = Stream.new
  end

  def new_from_resource
    @stream = Stream.new
  end

  def suggest
    res = Faraday.get "#{CONF['API_URL']}/suggest/#{params[:model]}?size=10"
    data = if res.status == 404 then {} else JSON.parse(res.body)['suggestions'] end
    render :json => data, :status => res.status
  end

  def fetchResource
    res = Faraday.get "#{CONF['API_URL']}/resources/#{params[:id]}"
    render :json => res.body, :status => res.status
  end

  def correctModelFields
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
    @stream.attributes.delete 'user_id'
    @stream.attributes.delete 'nr_subscribers'

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
    @user = current_user
    @stream = Stream.new(stream_params)
    correctModelFields

    respond_to do |format|
      res = post
      res.on_complete do
        if res.status == 200 and @stream.valid?

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
  end

  def update
    @user = current_user
    @stream.assign_attributes(stream_params)
    correctModelFields

    respond_to do |format|
      stream_id = @stream.id
      res = put
      res.on_complete do
        if res.status == 200 and @stream.valid?
          # TODO
          # The API is currently sending back the response before the database has
          # been updated. The line below will be removed once this bug is fixed.
          sleep(1.0)

          format.html { redirect_to stream_path(stream_id) }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @stream.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def destroy
    @user = current_user
    #@stream.destroy(_user_id: current_user.username)
    @stream.destroy
    Relationship.all.where(followed_id: @stream.id).each do |r|
      r.destroy
    end

    # TODO
    # The API is currently sending back the response before the database has
    # been updated. The line below will be removed once this bug is fixed.
    sleep(1.0)

    respond_to do |format|
      format.html { redirect_to "/users/#{@user.username}/streams" }
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
      res.on_complete do
        # format.html { redirect_to streams_path }
        format.html { redirect_to "/users/#{@user.username}/streams" }
        format.json { head :no_content }
      end
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
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  def post
    url = "#{CONF['API_URL']}/users/#{@user.username}/streams/"
    send_data(:post, url, @stream.attributes.to_json)
  end

  def put
    url = "#{CONF['API_URL']}/users/#{@user.username}/streams/#{@stream.id}"
    @stream.attributes.delete 'id'
    send_data(:put, url, @stream.attributes.to_json)
  end

  def deleteAll
    url = "#{CONF['API_URL']}/users/#{@user.username}/streams/"
    send_data(:delete, url, nil)
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      @stream = Stream.find(params[:id])
    end

    def get_current_user
      @user = current_user
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :longitude, :latitude, :polling, :uri, :polling_freq, :data_type, :parser)
    end

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
      stream = Stream.find(params[:id], :_user_id => current_user.username)
			@user = User.find_by_username(stream.user_id)
			redirect_to(root_url) unless current_user?(@user)
		end
end
