class StreamsController < ApplicationController

  before_action :set_stream, only: [:show, :edit, :update, :destroy]

  def index
    # @streams = Stream.search(params[:search])
    @streams = Stream.all(_user_id: current_user.id)
  end

  def show
  end

  def new
    @stream = Stream.new
    attributes = ["name", "description", "type", "private",
                  "tags", "accuracy", "unit", "min_val", "max_val", "latitude", "longitude",
                  "poll", "uri", "polling_freq",
                  "user_id"]
    attributes.each do |attr|
      @stream.send("#{attr}=", nil)
    end
  end

  def edit
  end

  def correctBooleanFields
    @stream.location = "#{@stream.latitude},#{@stream.longitude}"
    @stream.attributes.delete 'longitude'
    @stream.attributes.delete 'latitude'

    @stream.poll    = if @stream.poll    == "0" then "false" else "true" end
    @stream.private = if @stream.private == "0" then "false" else "true" end
    @stream.active  = "true"
  end

  def create
    @stream = Stream.new(stream_params)
    correctBooleanFields

    logger.debug "attributes"
    logger.debug @stream.attributes

    respond_to do |format|
    	res = post
      	if res.status == 200
          @stream.id = JSON.parse(res.body)['_id']
  				# TODO
          # The API is currently sending back the response before the database has
  				# been updated. The line below will be removed once this bug is fixed.
        	sleep(1.0)

  				format.html { redirect_to stream_path(@stream.id) }
        	format.json { render action: 'show', status: :created, location: @stream }
      	else
        	format.html { render action: 'new' }
        	format.json { render json: @stream.errors, status: :unprocessable_entity }
      	end
    end
  end

  def update
    @stream.assign_attributes(stream_params)
    correctBooleanFields

    respond_to do |format|
    	res = put
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
    respond_to do |format|
      format.json { render json: res.body, status: res.status }
    end
  end

  def deleteAll
    cid = current_user.id
    url = "#{CONF['API_URL']}/users/#{cid}/streams/"
    send_data(:delete, url)
  end

  def post
    cid = current_user.id
    url = "#{CONF['API_URL']}/users/#{cid}/streams/"
    send_data(:post, url)
  end

  def put
    cid = current_user.id
    url = "#{CONF['API_URL']}/users/#{cid}/streams/#{@stream.id}"
    send_data(:put, url)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      @stream = Stream.find(params[:id], _user_id: current_user.id)
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :longitude, :latitude, :poll, :uri, :polling_freq)
    end

    # def load_parent
    #   @user = User.find(current_user.id)
    # end

    def send_data(method, url)
      new_connection unless @conn
      @conn.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = @stream.attributes.to_json if @stream
      end
    end

    def new_connection
      cid = current_user.id
      @conn = Faraday.new(:url => "#{CONF['API_URL']}/users/#{cid}/") do |faraday|
        faraday.request  :url_encoded               # form-encode POST params
        faraday.response :logger                    # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter    # make requests with Net::HTTP
      end
    end
end
