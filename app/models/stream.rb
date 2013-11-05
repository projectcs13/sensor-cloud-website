class Stream
  include Her::Model

  attributes :name
	validates :name,  presence: true, length: { maximum:50 }

  belongs_to :resource
  # belongs_to :group

  collection_path "/users/:user_id/resources/:resource_id/streams"
  include_root_in_json false
  parse_root_in_json :hits, format: :active_model_serializers

  def post rid
    uid = current_user.id
    url = "#{CONF['API_URL']}/users/#{uid}/resources/#{rid.to_s}/streams/"
    send_data(:post, url)
  end

  def put rid, sid
    uid = current_user.id
    url = "#{CONF['API_URL']}/users/#{uid}/resources/#{rid.to_s}/streams/#{sid.to_s}"
    send_data(:put, url)
  end

  private
    def send_data(method, url)
      new_connection

      @conn.send(method) do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.body = @attributes.to_json
      end
    end

    def new_connection
      @conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end
end
