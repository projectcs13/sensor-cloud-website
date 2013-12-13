class Vstream
  include Her::Model

  attributes :name, :description, :user_id, :function, :streams_involved, :starting_date, :tags
	validates :name,  presence: true, length: { maximum:50 }

  belongs_to :user
  # belongs_to :multistream

	# has_many :reverse_relationships, foreign_key: "followed_id",
	# 																							class_name: "Relationship",
	# 																							dependent: :destroy
	# has_many :followers, through: :reverse_relationships, source: :follower

  #collection_path "/users/:user_id/streams"
  collection_path "vstreams"
  include_root_in_json false
  parse_root_in_json :vstreams, format: :active_model_serializers

  # def post uid
  #   url = "#{CONF['API_URL']}/vstreams"
  #   send_data(:post, url)
  # end

  # def put uid, sid
  #   url = "#{CONF['API_URL']}/vstreams"
  #   send_data(:put, url)
  # end

  # private
  #   def send_data(method, url)
  #     new_connection

  #     @conn.send(method) do |req|
  #       req.url url
  #       req.headers['Content-Type'] = 'application/json'
  #       req.body = @attributes.to_json
  #     end
  #   end

  #   def new_connection
  #     @conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
  #       faraday.request  :url_encoded             # form-encode POST params
  #       faraday.response :logger                  # log requests to STDOUT
  #       faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  #     end
  #   end
end
