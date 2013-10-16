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
  end

  # GET /resources/1/edit
  def edit
  end

  # POST /resources
  # POST /resources.json
  def create
    @resource = Resource.new(resource_params)

    t = Time.new
    # @resource.creation_date = t.year.to_s + '/' + t.month.to_s + '/' + t.day.to_s
    logger.debug ">> Create Resource: #{@resource}"
    respond_to do |format|
      if @resource.save
        format.html { redirect_to edit_resource_path(@resource) }
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
      # @resource.update_attributes(resource_params)
      @resource._source['name'] = "Testing BLABLABLA"
      # logger.debug ">>>>>>> Resource: #{@resource.methods.sort}"
      logger.debug ">>>>>>> Resource: #{@resource.class}"
      if @resource.name = @resource._source['name']
        format.html { redirect_to action: 'index', status: :moved_permanently }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @resource.errors, status: :unprocessable_entity }
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
      params.require(:resource).permit(:owner, :name, :description, :manufacturer, :model, :update_freq, :resource_type, :data_overview, :serial_num, :make, :location, :uri, :tags, :active, :id, :_id, :_source)
    end
end
