class Post < ActiveRecord::Base
	def product
		@product || = Product.find(:all)
	end
end
