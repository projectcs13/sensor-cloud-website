require 'spec_helper'

describe Stream do
  before do
  	@stream = Stream.new(
  		name: "Example Stream", 
  		description: "Example",
    	private: "true", 
    	accuracy: "1.2", 
    	longitude: "0.0",
    	latitude: "0.0", 
    	stream_type: "Temperature",
    	unit: "C",
    	max_val: "100",
    	min_val: "100",
    	active: "true",
    	tags: "Example",
    	resource_id: 1,
    	user_ranking: 5.0,
    	history_size: 120,
    	subscribers: 120,
    	)
  end

  subject{ @stream }
  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:private) }
  it { should respond_to(:accuracy) }
  it { should respond_to(:longitude) }
  it { should respond_to(:latitude) }
  it { should respond_to(:stream_type) }
  it { should respond_to(:unit) }
  it { should respond_to(:max_val) }
  it { should respond_to(:min_val) }
  it { should respond_to(:active) }
  it { should respond_to(:tags) }
  it { should respond_to(:resource_id) }
  it { should respond_to(:user_ranking) }
  it { should respond_to(:history_size) }
  it { should respond_to(:subscribers) }
  it { should be_valid }

  describe "when name is not present" do
	before { @stream.name = " " }
	it { should_not be_valid }
  end

  describe "resource association" do
  	let(:resource) { FactoryGirl.create(:resource) }
  	before { @stream = resource.streams.build(name: "Associated Stream") }

  	subject { @stream }

  	it { should respond_to(:name) }
  	it { should respond_to(:resource_id) }
  	it { should respond_to(:resource) }
  	its(:resource) { should eq resource }

  	it { should be_valid }

  	describe "when resource_id is not present" do
    	before { @stream.resource_id = nil }
    	it { should_not be_valid }
  	end 	
  end
end