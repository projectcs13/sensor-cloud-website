class User < ActiveRecord::Base
	VALID_EMAIL_REGEX = /\A[\w+\-.]+@[a-z\d\-.]+\.[a-z]+\z/i
	validates :username,  presence: true, length: { maximum:50 }, uniqueness: { case_sensitive: false }
    validates :email, presence: true, format: { with: VALID_EMAIL_REGEX }, uniqueness: { case_sensitive: false }
	validates :password, :presence     => true,
                     	:confirmation => true,
                     	:length       => { :minimum => 6 },
                     	:if           => :password
	validates :description, length: { maximum:500 }
	has_secure_password

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
		relationships.find_by(followed_id: stream_id)
	end

	def follow!(stream_id)
		relationships.create!(followed_id: stream_id)
	end

	def unfollow!(stream_id)
		relationships.find_by(followed_id: stream_id).destroy!
	end

	private
		def create_remember_token
			self.remember_token = User.encrypt(User.new_remember_token)
		end
end
