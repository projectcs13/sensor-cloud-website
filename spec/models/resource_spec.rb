=begin

require 'spec_helper'

describe Resource do

=begin
  before do
    @resource = Resource.new(name: "My new resource",
      owner: 5, description: "description", manufacturer: "Bosch", model: "mt-5000", creation_date: "2013-08-03",
      # polling_freq: 60,
      # type: "sensor",
      data_overview: "datadatadata", serial_num: "1890-AHC-92", make: "2", location: "Uppsala, Sweden",
      uri: "http://bosch.com", mirror_proxy: true
      # tags: "bosch, mt-5000, temperature",
      # active: true
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
            },
            {
              id: 2, owner: 0, name: "Seconds Resource", description: "Another description", manufacturer: "SICSth Sense",
              model: "si-123q", make: "5", serial_num: "5678-EFGH-654", creation_date: "2013-10-24", update_freq: "30",
              resource_type: "sensor", data_overview: "data data data", location: "Stockholme, Sweden",
              uri: "http://sensors.sics.se", tags: "sensor, sics, stockholme", active: false
            }
          ].to_json
        ]
      }
    end
  end

  describe "fetch all resources" do
    subject { Resource.all(_user_id: user_id) }
    its(:length) { should == 2 }
    its(:errors) { should be_empty }
  end

  describe "validate attributes" do
    # subject { @resource = Resource.find(1, _user_id: user_id) }
    subject { @resource = Resource.all(_user_id: user_id).first }

    it { should respond_to(:name) }
    it { should respond_to(:location) }
    it { should respond_to(:description) }
    it { should respond_to(:tags) }
    it { should respond_to(:creation_date) }

    it { should respond_to(:manufacturer) }
    it { should respond_to(:model) }
    it { should respond_to(:make) }
    it { should respond_to(:serial_num) }
    it { should respond_to(:update_freq) }
    it { should respond_to(:resource_type) }

    it { should respond_to(:uri) }
    it { should respond_to(:data_overview) }
    it { should respond_to(:active) }

    it { should respond_to(:owner) }

    # it { should respond_to(:mirror_proxy) }

    it { should be_valid }
=begin
    describe "when name is not present" do
      before { @resource.name = " " }
      it { should_not be_valid }
    end
#=end
  end

end

=end
