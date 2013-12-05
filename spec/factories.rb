FactoryGirl.define do
	factory :user do
		sequence(:username)  { |n| "Person_#{n}" }
		sequence(:email)     { |n| "person_#{n}@example.com" }
		password "foobar"
		password_confirmation "foobar"

		factory :admin do
			admin true
		end
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
