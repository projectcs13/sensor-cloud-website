class ResourcesController < ApplicationController

  before_action :set_resource, 	 only: [:show, :edit, :update, :destroy]

  ### TODO Testing Purpeses
  # current_user = { id: 0 }

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all(_user_id: current_user.id)
		# logger.debug ">> @resources: #{@resources.inspect}"
		#@resources.each do | r |
    #  logger.debug ">> RES: #{r.attributes}"
		#end
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    redirect_to :action => "edit"
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
    ### TODO Remove the owner
    @resource = Resource.new(resource_params)
    @resource.user_id = current_user.id

		if @resource.valid?
    	res = post
			sleep(1.0)
    	respond_to do |format|
      	if res.status == 200
        	id = JSON.parse(res.body)['_id']
        	format.html { redirect_to edit_resource_path(id) }
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
