FactoryGirl.define do
	factory :user do
		name 		 "Quentin Bahers"
		email 	 "qbahers@example.com"
		password "foobar"
		password_confirmation "foobar"
	end
	factory :resource do 
    	name "Example resource"
    	description "Example description"
    end
	factory :stream do
		name "Example stream"
    	resource
    end

end
