class ResourcesController < ApplicationController

  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  # GET /resources
  # GET /resources.json
  def index
    @resources = Resource.all
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    redirect_to :action => "edit"
  end

  # GET /resources/new
  def new
    @resource = Resource.new

    r = Resource.all.first
    r.attributes.each do |attr|
      @resource.send("#{attr[0]}=", nil)
    end

    @resource
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    ## TODO remove this line to make it work for every user
    @resource.owner = 0
    res = post
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
  end

  # PATCH/PUT /resources/1
  # PATCH/PUT /resources/1.json
  def update
    respond_to do |format|
      @resource.assign_attributes(resource_params)
      res = put
      res.on_complete do
        if res.status == 200
          format.html { redirect_to action: 'index', status: :moved_permanently }
          format.json { head :no_content }
        else
          format.html { render action: 'edit' }
          format.json { render json: @resource.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  # DELETE /resources/1
  # DELETE /resources/1.json
  def destroy
    @resource.destroy
    respond_to do |format|
      format.html { redirect_to resources_url }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_resource
      @resource = Resource.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def resource_params
      params.require(:resource).permit(:owner, :name, :description, :manufacturer, :model, :update_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active)
    end

    def post
      url = "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/"
      send_data(:post, url)
    end

    def put
      url = "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/" + @resource.id.to_s
      send_data(:put, url)
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
      @conn = Faraday.new(:url => 'http://srv1.csproj13.student.it.uu.se:8000/users/0/') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
end
