require 'json'

class StreamsController < ApplicationController

  before_action :set_stream, only: [:show, :edit, :update, :destroy]
  before_filter :load_parent, only: [:show, :edit, :update, :destroy]

  # GET /streams
  # GET /streams.json
  def index
    res = Faraday.get 'http://130.238.15.206:8000/streams'
    json = JSON.parse(res.body)
    @streams = json["hits"]["hits"]
  end

  # GET /streams/1
  # GET /streams/1.json
  def show
    # @stream = @resource.streams.find(params[:id])
  end

  # GET /streams/new
  def new
    @stream = @resource.streams.new
  end

  # GET /streams/1/edit
  def edit
    @stream = @resource.streams.find(params[:id])
  end

  # POST /streams
  # POST /streams.json
  def create
    # @stream = Stream.new(stream_params)
    # @stream = @resource.streams.new(params[:stream])
    @stream = @resource.streams.new(stream_params)

    respond_to do |format|
      if @stream.save
        # format.html { redirect_to @stream, notice: 'Stream was successfully created.' }
        # format.html { redirect_to [@resource, @stream], notice: 'Child was successfully created.' }
        # format.html { redirect_to @resource, notice: 'Stream was successfully created.' }
        format.html { redirect_to @resource }
        format.json { render action: 'show', status: :created, location: @stream }
      else
        format.html { render action: 'new' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /streams/1
  # PATCH/PUT /streams/1.json
  def update
    @stream = @resource.streams.find(params[:id])

    respond_to do |format|
      if @stream.update(stream_params)
        # format.html { redirect_to @stream, notice: 'Stream was successfully updated.' }
        # format.html { redirect_to [@resource, @stream], notice: 'Child was successfully updated.' }
        format.html { redirect_to edit_resource_path(@resource) }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @stream.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /streams/1
  # DELETE /streams/1.json
  def destroy
    #@stream = @resource.streams.find(params[:id])
    @stream.destroy
    respond_to do |format|
      # format.html { redirect_to streams_url }
      # format.html { redirect_to resource_streams_path(@resource) }
      format.html { redirect_to edit_resource_path(@resource) }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_stream
      @stream = Stream.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def stream_params
      params.require(:stream).permit(:name, :description, :private, :accuracy, :longitude, :latitude, :stream_type, :unit, :max_val, :min_val, :active, :tags, :resource_id, :user_id, :user_ranking, :history_size, :subscribers)
    end

    ### TODO doc
    def load_parent
      @resource = Resource.find(params[:resource_id])
    end

end
