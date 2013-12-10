class User < ActiveRecord::Base
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :username,  presence: true, length: { maximum:50 }, uniqueness: { case_sensitive: false }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }
	validates :description, length: { maximum:500 }


	has_many :streams
	has_many :relationships, foreign_key: "follower_id", dependent: :destroy
	has_many :followed_streams, through: :relationships, source: :followed

	before_save { self.email = email.downcase }
	before_create :create_remember_token

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def to_param
		username
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def feed
	end

	def following?(stream_id)
		response = Faraday.get "#{CONF['API_URL']}/users/#{self.username}"
		unless (JSON.parse(response.body)["subscriptions"]).empty?
			JSON.parse(response.body)["subscriptions"].include?({"stream_id"=>"#{stream_id}"})
		end
	end

	def follow!(stream_id)
		conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
		  faraday.request  :url_encoded             # form-encode POST params
		  faraday.response :logger                  # log requests to STDOUT
		  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
		end

		resp = conn.put do |req|
		  req.url "/users/#{self.username}/_subscribe"
		  req.headers['Content-Type'] = 'application/json'
		  req.body = "{\"stream_id\":\"#{stream_id}\"}"
		end
	end

	def unfollow!(stream_id)
		conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
		  faraday.request  :url_encoded             # form-encode POST params
		  faraday.response :logger                  # log requests to STDOUT
		  faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
		end

		resp = conn.put do |req|
		  req.url "/users/#{self.username}/_unsubscribe"
		  req.headers['Content-Type'] = 'application/json'
		  req.body = "{\"stream_id\":\"#{stream_id}\"}"
		end
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end
end
