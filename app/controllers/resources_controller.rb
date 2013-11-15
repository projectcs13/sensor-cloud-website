class ResourcesController < ApplicationController

  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  def index
    @resources = Resource.all(_user_id: current_user.id)
  end

  def show
    redirect_to :action => "edit"
  end

  def make_suggestion_by model
    res = Faraday.get "#{CONF['API_URL']}/suggest/#{model}"

    if res.status == 404
      data = {}
    else
      suggestion = JSON.parse(res.body)['suggestions'][0]
      data = suggestion['payload']
    end

    data
  end

  def create_streams_to_resource
    sug = make_suggestion_by @resource.model
    streams = sug['streams']
    if streams
      streams.each do |st|
        # st['min_val'] = st['min_value']
        # st['max_val'] = st['max_value']
        st.delete('resource_id')

        s = Stream.new st

        res = s.post current_user.id, @resource.id
        logger.debug "JSON: #{res.body}"
        logger.debug "New Stream: #{s.attributes}"
      end
    end
  end

  def autocomplete
    name = params[:term]
    attribute = params[:attr]
    res = Faraday.get "#{CONF['API_URL']}/suggest/#{attribute}/#{name}"

    data = []
    unless res.status == 404
      sugs = JSON.parse(res.body)['suggestions']
      sugs.each do |s|
        data.push ({ :value => s['text'] })
      end
    end

    logger.debug "DATA: #{data}"
    render :json => data, :status => res.status
  end

  def suggest
    sug = make_suggestion_by params[:model]
    status = if sug then 200 else 404 end
    render :json => sug, :status => status
  end

  def new
    @resource = Resource.new
    # attributes = [:name, :description, :manufacturer, :model, :polling_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active]
    attributes = ["user_id","name","tags","model","description","type","manufacturer","uri","polling_freq","creation_date","uuid"]
    attributes.each do |attr|
      @resource.send("#{attr}=", nil)
    end
  end

  def edit
  end

  def create
    @resource = Resource.new(resource_params)
    @resource.user_id = current_user.id

    if @resource.valid?
      res = post

      respond_to do |format|
        if res.status == 200
          @resource.id = JSON.parse(res.body)['_id']

          if params[:suggestion] == "1"
            create_streams_to_resource
          end

          # TODO API should skip this attribute
          # @resource.attributes.delete 'suggestion'

          # The API is currently sending back the response before the database has
          # been updated. The line below will be removed once this bug is fixed.
          sleep(1.0)


          format.html { redirect_to edit_resource_path(@resource.id) }
          format.json { render action: 'show', status: :created, location: @resource }
        else
          format.html { render action: 'new' }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    else
      respond_to do |format|
        format.html { render action: 'new' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def update
    respond_to do |format|
      @resource.assign_attributes(resource_params)
      if @resource.valid?
        res = put
        sleep(1.0)
        res.on_complete do
          if res.status == 200
            format.html { redirect_to action: 'index', status: :moved_permanently }
            format.json { head :no_content }
          else
            format.html { render action: 'edit' }
            format.json { render json: @resource.errors, status: :unprocessable_entity }
          end
        end
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @resource.destroy
    sleep(1.0)
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def post
    url = "#{CONF['API_URL']}/users/#{current_user.id}/resources/"
    send_data(:post, url)
  end

  def put
    url = "#{CONF['API_URL']}/users/#{current_user.id}/resources/" + @resource.id.to_s
    send_data(:put, url)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id], user_id: current_user.id)
      # @resource.streams = Stream.all(:resource_id => :id)
      #logger.debug "#{@resource.streams}"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      # params.require(:resource).permit(:user_id, :name, :description, :manufacturer, :model, :polling_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active, :suggestion)
      params.require(:resource).permit("user_id","name","tags","model","description","type","manufacturer","uri","polling_freq","creation_date","uuid")
    end

    def send_data(method, url)
      new_connection

      @conn.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = @resource.attributes.to_json(:only => [:user_id, :name, :description, :manufacturer, :model, :polling_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active])
      end
    end

    def new_connection
      @conn = Faraday.new(:url => "#{CONF['API_URL']}/users/#{current_user.id}/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
end
