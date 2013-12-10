class Stream
  include Her::Model

  attributes :name, :description, :type, :private, :tags, :accuracy, :unit, :min_val, :max_val, :latitude, :longitude, :polling, :uri, :polling_freq, :data_type, :parser, :user_id
	validates :name,  presence: true, length: { maximum: 50 }

  belongs_to :user

	has_many :reverse_relationships,  foreign_key: "followed_id",
																		class_name: "Relationship",
																	  dependent: :destroy

  has_many :followers, through: :reverse_relationships, source: :follower

  collection_path "streams"
  include_root_in_json false
  parse_root_in_json :streams, format: :active_model_serializers
end
