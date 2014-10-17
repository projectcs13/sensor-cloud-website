class StreamsController < ApplicationController

  before_action :correct_user,     only: [:edit, :update, :destroy]
  before_action :get_current_user, only: [:index, :get_streams, :show, :new, :edit, :create, :update, :destroy, :destroyAll, :post, :put, :deleteAll, :new_connection]
  before_action :new_stream,       only: [:new, :new_from_resource]
  before_action :set_stream,       only: [:show, :edit, :update, :destroy]
  before_action :signed_in_user,   only: [:index, :edit, :update, :destroy]

  def index
    res = Api.get "/users/#{params[:id]}/streams", openid_metadata
    check_new_token res
    @streams = res["body"]["streams"]
    logger.debug "STREAMS: #{@streams}"
    @streams
  end

  def new
    if session[:stream]
      @stream = session[:stream]
      session[:stream] = nil
    end
  end

  def get_streams
    redirect_to "/users/#{@user.username}/streams"
  end

  def show
    @stream_id = params[:id]
    res = Api.get "/streams/#{@stream_id}", openid_metadata
    check_new_token res
    if res["status"] == 401
      flash[:warning] = "Not authorized access to private resources."
      redirect_to "/not_allowed_access"
    else
      @stream = Stream.new
      res["body"].each do |k, v|
        @stream.send("#{k}=", v)
      end
      stream_owner_id = res["body"]["user_id"]
      @stream_owner = User.find_by(username: stream_owner_id)

      @triggers = nil
      if signed_in? and current_user.username == @stream_owner.username then
        triggers = "/users/#{@stream_owner.username}/streams/#{@stream_id}/triggers"
        response = Api.get triggers, openid_metadata
        check_new_token response
        @triggers = response['body']['triggers']
      end
      @functions = {"greater_than" => "Greater than", "less_than" => "Less than", "span" => "Span"}

      @prediction = {:in => "50", :out => "25"}
      @polling_history = nil
      if res["body"]["polling"] == true then
        res2 = Api.get "/streams/#{@stream_id}/pollinghistory", openid_metadata
        check_new_token res2
        @polling_history = res2["body"]["history"]
        sorted_history = @polling_history.sort_by { |hsh| hsh[:timestamp] }.reverse
        @polling_history = sorted_history
      end

      res = Api.get "/streams/#{params[:id]}/data/_count", openid_metadata
      check_new_token res
      @count_history = res["body"]["count"]
    end
  end

  def suggest
    uri = ERB::Util.url_encode params[:model]

    res = Api.get "/suggest/#{uri}?size=10", openid_metadata
    check_new_token res
    data = if res["status"] == 404 then {} else res["body"]["suggestions"] end
    render :json => data, :status => res["status"]
  end

  def fetchResource
    res = Api.get "/resources/#{params[:id]}", openid_metadata
    check_new_token res
    render :json => res["body"], :status => res["status"]
  end

  def correctModelFields
    # This is due to the 'Bootstrap Switch' plugin
    @stream.polling = if @stream.polling == "0" then true  else false end
    @stream.private = if @stream.private == "0" then false else true  end

    @stream.resource = {:resource_type => @stream.resource_type, :uuid =>  @stream.uuid}
    @stream.location = { :lat => @stream.latitude.to_f, :lon => @stream.longitude.to_f }

    [ 'id', 'resource_type', 'uuid', 'longitude', 'latitude', 'active', 'user_ranking', 'last_updated',
      'history_size', 'creation_date', 'quality', 'subscribers', 'user_id', 'nr_subscribers' ].each do |attr|
      @stream.attributes.delete attr
    end

    ['accuracy', 'min_val', 'max_val', 'polling_freq'].each do |method|
      if @stream.send(method) == "" then @stream.send("#{method}=", nil) end
      if method == 'polling_freq'   then @stream.polling_freq = @stream.polling_freq.to_i end
    end
  end

  def create
    @stream = Stream.new stream_params
    correctModelFields

    respond_to do |format|
      if @stream.valid?
        res = Api.post "/users/#{@user.username}/streams", @stream.attributes, openid_metadata
        res["response"].on_complete do
          check_new_token res
          if res["status"] == 200

            @stream.id = res["body"]["_id"]
            # TODO
            # The API is currently sending back the response before the database has
            # been updated. The line below will be removed once this bug is fixed.
            sleep(1.0)
            format.html { redirect_to stream_path(@stream.id) }
            format.json { render json: {"id" => @stream.id}, status: res.status }
          else
            format.html { render new_stream_path, :flash => { :error => "Insufficient rights!" } }
            format.json { render json: {"error" => @stream.errors}, status: :unprocessable_entity }
          end
        end
      else
        format.html {
          session[:stream] = @stream
          redirect_to new_stream_path
        }
        format.json { render json: {"error" => @stream.errors}, status: :unprocessable_entity }
      end
    end
  end

  def update
    @stream.assign_attributes stream_params
    logger.debug "BEFORE CORRECTFEILDS: #{@stream.attributes}"
    correctModelFields
    logger.debug "AFTER CORRECTFEILDS: #{@stream.attributes}"

    respond_to do |format|
      stream_id = params[:id]
      res = Api.put "/streams/#{stream_id}", @stream.attributes, openid_metadata
      res["response"].on_complete do
        check_new_token res
        if res["status"] == 200 and @stream.valid?
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

  def edit
    longitude = @stream.location['lon']
    latitude = @stream.location['lat']
    @stream.attributes = {:latitude => latitude}
    @stream.attributes = {:longitude => longitude}
  end

  def destroy
    @user = current_user
    res = Api.delete "/streams/#{params[:id]}", nil, openid_metadata
    check_new_token res
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
    res = Api.delete "/users/#{@user.username}/streams/", nil, openid_metadata
    check_new_token res
    # TODO
    # The API is currently sending back the response before the database has
    # been updated. The line below will be removed once this bug is fixed.
    sleep(1.0)

    respond_to do |format|
      res["response"].on_complete do
        format.html { redirect_to "/users/#{@user.username}/streams" }
        format.json { head :no_content }
      end
    end
  end

  def fetch_datapoints
    res = Api.get "/streams/#{params[:id]}/data/_search", openid_metadata
    check_new_token res
    respond_to do |format|
      format.json { render json: res["body"], status: res["status"] }
    end
  end

  def fetch_prediction
    prediction = "/streams/#{params[:id]}/_analyse?nr_values=#{params[:in]}&nr_preds=#{params[:out]}"
    res = Api.get prediction, openid_metadata
    check_new_token res
    logger.debug "S:"
    respond_to do |format|
      format.js { render "fetch_prediction", :locals => {:data => res["body"].to_json} }
    end
  end

  def fetch_semantics
    file_type = params[:type]
    res = if "#{file_type}" == "ns3"
	    Api.semantics_get "/datapoints/#{params[:id]}"
    else
	    Api.semantics_get "/datapoints/#{params[:id]}?format=#{file_type}"
    end
    puts "RES, #{res}"
    sleep 0.5
    File.open("#{Dir.pwd}/public/semantics_output.#{file_type}", 'w') do |f|
      f.write(res["body"]);
      f.close
    end
  end

  def download
    send_file "#{Dir.pwd}/public/semantics_output.txt"
  end

  def fetch_datapreview
    res = Api.get "#{params[:uri]}", openid_metadata
    check_new_token res
    respond_to do |format|
      format.json { render json: res["body"], status: res["status"] }
    end
  end

  private
    # Aux Functions

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :longitude, :latitude, :polling, :uri, :polling_freq, :data_type, :parser, :resource_type, :uuid)
    end

    # Before filters

    def correct_user
      if current_user.nil?
        redirect_to("/streams/#{params[:id]}")
      else
        stream = Stream.find(params[:id], :_user_id => current_user.username)
        user = User.find_by_username(current_user.username)
        redirect_to("/streams/#{params[:id]}") unless current_user?(user)
      end
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
