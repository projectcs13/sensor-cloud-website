class User < ActiveRecord::Base

  validates :description, length: { maximum:500 }

	has_many :streams

	before_save :downcase_attributes

	def User.new_remember_token
		SecureRandom.urlsafe_base64
	end

	def User.encrypt(token)
		Digest::SHA1.hexdigest(token.to_s)
	end

	def following?(stream_id, openid_metadata)
		res = Api.get "/users/#{self.username}", openid_metadata
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

end
