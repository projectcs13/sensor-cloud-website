=begin

require 'spec_helper'

describe Stream do
=begin
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
#=end

  user_id = 0

  before do
    stub_api_for(Resource) do |stub|
      stub.get("/users/#{user_id}/resources") { |env|
        [200, {}, [
            {
              id: 1, owner: 0, name: "First Resource", description: "Some description", manufacturer: "Ericsson",
              model: "er-500t", make: "2", serial_num: "1234-ABCD-987", creation_date: "2013-08-23", update_freq: "60",
              resource_type: "sensor", data_overview: "data data data", location: "Uppsala, Sweden",
              uri: "http://sensors.ericsson.se", tags: "sensor, ericsson, uppsala", active: true
            }
          ].to_json
        ]
      }

      stub.get("/users/#{user_id}/resources/1/streams") { |env|
        [200, {}, [
            {
              id: 1, owner_id: 0, resource_id: 1, name: "First Stream", description: "A stream"
            }
          ].to_json
        ]
      }
    end
  end

  before {
    resource = Resource.all(_user_id: user_id).first
    # resource.streams = Stream.all({resource_id: resource.id, _user_id: user_id})
    # @streams = resource.streams
    @streams = Stream.all({resource_id: resource.id, _user_id: user_id})
  }

  subject { @streams }

  describe "fetch all streams which belong to a specific resource" do
    its(:length) { should == 1 }
    its(:errors) { should be_empty }
  end

  describe "validate attributes" do
    subject { @stream = @streams.first }
    it { should respond_to(:name) }
    it { should respond_to(:description) }
=begin
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
#=end
    it { should be_valid }

=begin
    describe "when name is not present" do
    	before { @stream.name = " " }
    	it { should_not be_valid }
    end
=end

=begin
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
#=end

  end

end

=end
