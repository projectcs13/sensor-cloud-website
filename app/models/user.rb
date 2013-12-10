class User < ActiveRecord::Base
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :username,  presence: true, length: { maximum:50 }, uniqueness: { case_sensitive: false }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
	validates :password, length: { minimum: 6 }
	validates :description, length: { maximum:500 }

	has_many :streams

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

	def following?(stream_id)
		res = Api::Api.new.get("/users/#{self.username}")
		unless (res["subscriptions"]).empty?
			res["subscriptions"].include?({"stream_id"=>"#{stream_id}"})
		end
	end

	def follow!(stream_id)
		res = Api::Api.new.put(
			"/users/#{self.username}/_subscribe", {stream_id: "#{stream_id}"}
		)
	end

	def unfollow!(stream_id)
		res = Api::Api.new.put(
			"/users/#{self.username}/_unsubscribe", {stream_id: "#{stream_id}"}
		)
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end
end
