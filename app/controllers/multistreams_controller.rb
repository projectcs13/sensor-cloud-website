class MultistreamsController < ApplicationController

  # before_action :set_stream, only: [:show, :edit, :update, :destroy]
  # before_action :signed_in_user, only: [:index, :edit, :update, :destroy]
  # before_action :correct_user,   only: [:edit, :update, :destroy]

  # def index
  # end

  # def show
  # end

  def new
  end

  def edit
    @multistream = Multistream.new
    @multistream.streams.build
    # = [{name: "1", description: "desc"},{name: "2", description: "desc"},{name: "3", description: "desc"}]
  end

  def create
    logger.debug "CREATE: #{params}"
    # @multistream = Multistream.new(multistream_params)
    @multistream = Multistream.new
    params[:multistream].each do |k, v|
      logger.debug "Value: #{v}"
      st = @multistream.streams.build v
      logger.debug "Stream created: #{st.attributes}"
    end

    respond_to do |format|
      logger.debug "#{format}"
      format.html { redirect_to new_multistream_path }
      format.json { redirect_to new_multistream_path }
    end
    # logger.debug "Multistream: #{@multistream.attributes}"

    # respond_to do |format|
    #   res = post
    #     logger.debug "BODY: #{res.body}"
    #     if res.status == 200

    #       @stream.id = JSON.parse(res.body)['_id']
    #       # TODO
    #       # The API is currently sending back the response before the database has
    #       # been updated. The line below will be removed once this bug is fixed.
    #       sleep(1.0)

    #       format.html { redirect_to stream_path(@stream.id) }
    #       format.json { render action: 'show', status: :created, location: @stream }
    #     else
    #       format.html { render action: 'new' }
    #       format.json { render json: @stream.errors, status: :unprocessable_entity }
    #     end
    # end
  end

  def update
    @multistream.assign_attributes(multistream_params)
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
    @stream.attributes.delete 'id'
    send_data(:put, url)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      #@stream = Stream.find(params[:id], _user_id: current_user.id)
      @stream = Stream.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def multistream_params
      #params.require(:multistream).permit(:name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :longitude, :latitude, :polling, :uri, :polling_freq)
      params
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

    # Before filters
    def signed_in_user
      unless signed_in?
        store_location
        flash[:warning] = "Please sign in"
        redirect_to signin_url
      end
    end

    def correct_user
      @user = User.find(Stream.find(params[:id]).user_id)
      redirect_to(root_url) unless current_user?(@user)
    end
end
