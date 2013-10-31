class ResourcesController < ApplicationController

  before_action :set_resource, only: [:show, :edit, :update, :destroy]
  # before_action :set_resource, only: [:show, :edit, :update, :destroy, :suggest]

  ### TODO Testing Purposes
  # current_user = { id: 0 }

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all(_user_id: current_user.id)


		#@resources.each do | r |
    #  r.send("id=", "l6c-3LytRyO8KLrQhKA8qQ")
		#end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    redirect_to :action => "edit"
  end

  def parseSuggestion resBody
    suggestion = JSON.parse(resBody)['testsuggest'][0]
    if suggestion
      opt = suggestion['options'].last
      payload = opt['payload']
    end
  end

  def createResource resourceJSON
    @resource = Resource.new

    # attributes = [:name, :description, :manufacturer, :update_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active]
    # attributes.each do |attr|
    #   resource.send("#{attr}=", "")
    # end

    resourceJSON.each do |k, v|
      @resource.send("#{k}=", v)
    end

    @resource
  end

  def createStreams streamsJSON
    attributes = [:name, :description, :private, :accuracy, :longitude, :latitude, :stream_type, :unit, :max_val, :min_val, :active, :tags, :resource_id, :user_id, :user_ranking, :history_size, :subscribers, :updated_at, :created_at]
    logger.debug "Data: #{streamsJSON}"

    res = []
    streamsJSON.each do |stJSON|
      stream = Stream.new

      attributes.each do |a|
        stream.send("#{a}=", "")
      end

      stJSON.each do |k, v|
        stream.send("#{k}=", v)
      end

      res.push stream
    end

    @streams = res
  end

  # GET /suggest/1.json
  def suggest
    model = params[:resource][:model]
    res = Faraday.get "http://srv1.csproj13.student.it.uu.se:8000/suggest/#{model}"

    payload = parseSuggestion res.body
    if payload
			@resource = createResource params[:resource]

      logger.debug "Resource: #{@resource}"
      logger.debug "Resource: #{@resource.attributes}"
      logger.debug "Payload: #{payload}"

			payload.each do | attr, val |

        logger.debug "Attr: #{attr}"
        logger.debug "Val: #{val}"

        if attr == 'streams'
          @resource.send("#{attr}=", [])
          streams = createStreams val
          # streams.each do |st|
          #   @resource.streams.push st
          # end
        else
          @resource.send("#{attr}=", val)
        end
			end
		  logger.debug "RES: #{@resource.attributes}"
    end


		respond_to do |format|
			format.js
		end
  end

  # GET /resources/new
  def new
    @resource = Resource.new
    attributes = [:owner, :name, :description, :manufacturer, :model, :update_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active]
    attributes.each do |attr|
      @resource.send("#{attr}=", nil)
    end
    # @resource.send("#{user_id}=", current_user.id)
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    # @resource.assign_attributes(resource_params)
    logger.debug "CREATE: #{@resource.attributes}"
    ### TODO Remove the user_id ???
    @resource.user_id = current_user.id

		if @resource.valid?
    	res = post
			sleep(1.0)
    	respond_to do |format|
      	if res.status == 200
        	rid = JSON.parse(res.body)['_id']

          # @streams.each do |st|
          #   st.resource_id = rid
          #   st.post rid
          # end

        	format.html { redirect_to edit_resource_path(rid) }
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

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
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

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    # @resource.user_id = 0
    @resource.destroy
		sleep(1.0)
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  def post
    url = "http://srv1.csproj13.student.it.uu.se:8000/users/#{current_user.id}/resources/"
    send_data(:post, url)
  end

  def put
    url = "http://srv1.csproj13.student.it.uu.se:8000/users/#{current_user.id}/resources/" + @resource.id.to_s
    send_data(:put, url)
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id], user_id: current_user.id)
      logger.debug "id: #{@resource.id} - model: #{@resource.model}"
      # @resource.streams = Stream.all(:resource_id => :id)
      #logger.debug "#{@resource.streams}"
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:user_id, :name, :description, :manufacturer, :model, :update_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active)
    end

    def send_data(method, url)
      new_connection

      @conn.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = @resource.attributes.to_json
      end
    end

    def new_connection
      logger.debug "New Connection!!!!!!!!!!!!!!!!!!!!!!!!!!1"
      @conn = Faraday.new(:url => "http://srv1.csproj13.student.it.uu.se:8000/users/#{current_user.id}/") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
end
