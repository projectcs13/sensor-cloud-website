class ResourcesController < ApplicationController

  before_action :set_resource, only: [:show, :edit, :update, :destroy]

  # protect_from_forgery with: :null_session
  # protect_from_forgery secret: "1234567890123456789012345678901234"
  # skip_before_filter:verify_authenticity_token

  # uses one of the other session stores that uses a session_id value.
  #protect_from_forgery :secret => 'my-little-pony', :except => :index

  # you can disable csrf protection on controller-by-controller basis:
  # skip_before_filter :verify_authenticity_token

  # GET /resources
  # GET /resources.json
  def index
    #r = Resource.new(name: "Alberto", owner: 0)
    #logger.debug("r.attributes: #{r.attributes}")
    #logger.debug("r.valid?: #{r.valid?}")
    # r.save
    # Faraday.post "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources", r.attributes.to_json
    # Faraday.put "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/7F845um4SpCnmxpLm7SkFg/", { :name => 'Maguro' }\
    #h = {:name => 'Tomasaaaa Resource', :owner => 0}
    #response2 = Faraday.post 'http://srv1.csproj13.student.it.uu.se:8000/users/0/resources', h.to_json
    #logger.debug ">> #{response2.body}"
    #response3 = Faraday.put 'http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/7F845um4SpCnmxpLm7SkFg', {:name => 'test2 jose'}.to_json
    #logger.debug ">> #{response3.body}"
    #js = { :name => "kkkkkkkk" }.to_json
    #logger.debug ">> JS: #{js}"
    #res = HTTParty.put "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/7F845um4SpCnmxpLm7SkFg", :body => js, :headers => { 'Content-Type' => 'application/json' }
    #logger.debug ">> RES: #{res}"
    @resources = Resource.all
  end

  # GET /resources/1
  # GET /resources/1.json
  def show
    redirect_to :action => "edit"
  end

  # GET /resources/new
  def new
    r = Resource.find("bNEuQ1-pQz6qVQvBqzvt3g")
    logger.debug "#{r.attributes}"
    @resource = Resource.new
    r.attributes.each do |attr|
      key = attr[0]
      val = attr[1]
      if key == "id"
        @resource.send("#{key}=", nil)
      else
        @resource.send("#{key}=", val)
      end
    end
    logger.debug "#{@resource.attributes}"
    @resource
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)
    @resource.owner = 0
    # @resource.creation_date = t.year.to_s + '/' + t.month.to_s + '/' + t.day.to_s
    logger.debug ">> Create Resource: #{@resource.attributes}"
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
        # logger.debug ">>>>> STATUS: #{res.status}"
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
      new_connection
      url = "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/"
      @conn.post do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = @resource.attributes.to_json
      end
    end

    def put
      new_connection
      url = "http://srv1.csproj13.student.it.uu.se:8000/users/0/resources/"
      target = url.to_s + @resource.id.to_s
      #opts = { :headers => { 'Content-Type' => 'application/json' } }
      #json = @resource.attributes.to_json
      #logger.debug "JSON: #{json}"
      # HTTParty.put target, :body => json, :options => opts
      @conn.put do |req|
        req.url target
        req.headers['Content-Type'] = 'application/json'
        req.body = @resource.attributes.to_json
      end
    end

    def new_connection
      logger.debug "New Connection!!!!!!!!!!!!!!!!!!!!!!!!!!1"
      @conn = Faraday.new(:url => 'http://sushi.com') do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
end
