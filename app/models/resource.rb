class Resource < ActiveResource::Base
  self.site = "http://130.238.15.197:8000/users/1/resources/"

  has_many :streams

  validates :name, presence: true
end
