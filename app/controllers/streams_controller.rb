class StreamsController < ApplicationController

  before_action :load_parent
  before_action :set_stream, only: [:show, :edit, :update, :destroy]


  # GET /streams
  # GET /streams.json
  def index
    @streams = Stream.search(params[:search])
  end

  # GET /streams/1
  # GET /streams/1.json
  def show
  end

  # GET /streams/new
  def new
    @stream = @resource.streams.build
    attributes = [:name, :description, :private, :accuracy, :longitude, :latitude, :stream_type, :unit, :max_val, :min_val, :active, :tags, :resource_id, :user_id, :user_ranking, :history_size, :subscribers, :updated_at, :created_at]
    attributes.each do |attr|
      @stream.send("#{attr}=", nil)
    end
    @stream
  end

  # GET /streams/1/edit
  def edit
  end

  # POST /streams
  # POST /streams.json
  def create
    # @stream = @resource.streams.create(stream_params)
    @stream = Stream.new(stream_params)
    if @stream.private == "0"
      @stream.private = "false"
    else
      @stream.private = "true"
    end

    if @stream.active == "0"
      @stream.active = "false"
    else
      @stream.active = "true"
    end
		@resource.streams.push @stream

    logger.debug ">>>>> Attributes}"
    logger.debug "#{@resource.attributes}"
    logger.debug "#{@stream.attributes}"

    respond_to do |format|
			if @stream.valid?
      	res = post
      	if res.status == 200
        	# format.html { redirect_to @stream, notice: 'Stream was successfully created.' }
        	# format.html { redirect_to [@resource, @stream], notice: 'Child was successfully created.' }
        	# format.html { redirect_to @resource, notice: 'Stream was successfully created.' }
        	sleep(1.0)
					format.html { redirect_to @resource }
        	format.json { render action: 'show', status: :created, location: @stream }
      	else
        	format.html { render action: 'new' }
        	format.json { render json: @stream.errors, status: :unprocessable_entity }
      	end
			else
        format.html { render action: 'new' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
			end
    end
  end

  # PATCH/PUT /streams/1
  # PATCH/PUT /streams/1.json
  def update
    respond_to do |format|
      @stream.assign_attributes(stream_params)
			if @stream.valid?
        if @stream.private == "0"
          @stream.private = "false"
        else
          @stream.private = "true"
        end

        if @stream.active == "0"
          @stream.active = "false"
        else
          @stream.active = "true"
        end
      	res = put
      	res.on_complete do
        	if res.status == 200
						sleep(1.0)
          	format.html { redirect_to edit_resource_path(@resource) }
          	format.json { head :no_content }
        	else
          	format.html { render action: 'edit' }
          	format.json { render json: @stream.errors, status: :unprocessable_entity }
        	end
      	end
			else
      	format.html { render action: 'edit' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
			end
    end
  end

  # DELETE /streams/1
  # DELETE /streams/1.json
  def destroy
    @stream.destroy
    # @resource.streams.delete @stream.id
    # @resource.put
		sleep(1.0)
    respond_to do |format|
      # format.html { redirect_to streams_url }
      # format.html { redirect_to resource_streams_path(@resource) }
      format.html { redirect_to edit_resource_path(@resource) }
      format.json { head :no_content }
    end
  end

  def fetch_datapoints
    res = Faraday.get "#{CONF['API_URL']}/streams/" + params[:id] + "/data/_search"
    respond_to do |format|
      format.json { render json: res.body, status: 200 }
    end
  end

  def fetch_prediction
    res = Faraday.get "#{CONF['API_URL']}/streams/" + params[:id] + "/_analyse"
    respond_to do |format|
      format.json { render json: res.body, status: 200 }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      @stream = Stream.find(params[:id], _resource_id: @resource.id, _user_id: current_user.id)
      # @stream = @resource.streams.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :private, :accuracy, :longitude, :latitude, :stream_type, :unit, :max_val, :min_val, :active, :tags, :resource_id, :user_id, :user_ranking, :history_size, :subscribers, :created_at)
    end

    ### TODO doc
    def load_parent
      @resource = Resource.find(params[:resource_id], _user_id: current_user.id)
    end

    def post
      cid = current_user.id
      url = "#{CONF['API_URL']}/users/#{cid}/resources/" + @resource.id.to_s + "/streams/"
      send_data(:post, url)
    end

    def put
      cid = current_user.id
      url = "#{CONF['API_URL']}/users/#{cid}/resources/" + @resource.id.to_s + "/streams/" + @stream.id.to_s
      send_data(:put, url)
    end

    def send_data(method, url)
      new_connection
      logger.debug "JSON: #{@stream.attributes.to_json}"
      @conn.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = @stream.attributes.to_json
      end
    end

    def new_connection
      cid = current_user.id
      @conn = Faraday.new(:url => "#{CONF['API_URL']}/users/#{cid}/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
end
