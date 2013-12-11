class StreamsController < ApplicationController

  before_action :correct_user,     only: [:edit, :update, :destroy]
  before_action :get_current_user, only: [:index, :get_streams, :show, :new, :edit, :create, :update, :destroy, :destroyAll, :post, :put, :deleteAll, :new_connection]
  before_action :new_stream,       only: [:new, :new_from_resource]
  before_action :set_stream,       only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user,   only: [:index, :edit, :update, :destroy]

  def index
    res = Api.get("/users/#{@user.username}/streams")
    @streams = res['streams']
  end

  def get_streams
    redirect_to "/users/#{@user.username}/streams"
  end

  def show
		@stream_id = params[:id]
    res = Api.get("/streams/#{@stream_id}")
    stream_owner_id = res['user_id']
		@stream_owner = User.find_by(username: stream_owner_id)
  end

  def suggest
    res = get "/suggest/#{params[:model]}?size=10"
    data = if res.status == 404 then {} else JSON.parse(res.body)['suggestions'] end
    render :json => data, :status => res.status
  end

  def fetchResource
    res = get "/resources/#{params[:id]}"
    render :json => res.body, :status => res.status
  end

  def correctModelFields
    @stream.polling = if @stream.polling == "1" then false else true end
    @stream.private = if @stream.private == "0" then false else true end

    @stream.resource = {:resource_type => @stream.resource_type, :uuid =>  @stream.uuid}
    @stream.location = { :lat => @stream.latitude.to_f, :lon => @stream.longitude.to_f }

    ['resource_type', 'uuid', 'longitude', 'latitude', 'active', 'user_ranking', 'last_updated',
      'history_size', 'creation_date', 'quality', 'subscribers', 'user_id', 'nr_subscribers' ].each do |attr|
      @stream.attributes.delete attr
    end

    ['accuracy', 'min_val', 'max_val', 'polling_freq'].each do |method|
      if @stream.send(method) == "" then @stream.send(method, nil) end
      if method == 'polling_freq'   then @stream.polling_freq = @stream.polling_freq.to_i end
    end
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
        format.html { redirect_to "/users/#{@user.username}/streams" }
        format.json { head :no_content }
      end
    end
  end

  def fetch_datapoints
    res = Faraday.get "#{CONF['API_URL']}/streams/#{params[:id]}/data/_search"
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  def fetch_prediction
    res = Faraday.get "#{CONF['API_URL']}/streams/#{params[:id]}/_analyse"
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
    # Aux Functions

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :longitude, :latitude, :polling, :uri, :polling_freq, :data_type, :parser, :resource_type, :uuid)
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
      @conn = Faraday.new(:url => "#{CONF['API_URL']}/users/#{@user.username}/") do |faraday|
        faraday.request  :url_encoded               # form-encode POST params
        faraday.response :logger                    # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter    # make requests with Net::HTTP
      end
		end

		# Before filters

    def correct_user
      stream = Stream.find(params[:id], :_user_id => current_user.username)
      user = User.find_by_username(stream.user_id)
      redirect_to(root_url) unless current_user?(user)
    end

    def get_current_user
      @user = current_user
    end

    def new_stream
      @stream = Stream.new
    end

    def set_stream
      @stream = Stream.find(params[:id])
    end

		def signed_in_user
			unless signed_in?
				store_location
				flash[:warning] = "Please sign in"
				redirect_to signin_url
			end
		end
end
