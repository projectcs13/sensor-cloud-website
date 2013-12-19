class User < ActiveRecord::Base

	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	VAILD_USERNAME_REGEX = /\A[a-zA-Z0-9_-]+\Z/
  validates :username,  presence: true, format: { with: VAILD_USERNAME_REGEX }, length: { maximum:50 }, uniqueness: { case_sensitive: false }
  validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	has_secure_password
  validates :password, length: { minimum: 6 }
  validates :description, length: { maximum:500 }

	has_many :streams

	before_save :downcase_attributes
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
		res = Api.get("/users/#{self.username}")
		unless (res['body']["subscriptions"]).empty?
			res['body']["subscriptions"].include?({"stream_id"=>"#{stream_id}"})
		end
	end

	def follow!(stream_id)
		Api.put "/users/#{self.username}/_subscribe", { stream_id: "#{stream_id}" }
	end

	def unfollow!(stream_id)
		Api.put "/users/#{self.username}/_unsubscribe", { stream_id: "#{stream_id}" }
	end


	private

		def downcase_attributes
			self.username = self.username.downcase
			self.email = self.email.downcase
		end

		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end
end
