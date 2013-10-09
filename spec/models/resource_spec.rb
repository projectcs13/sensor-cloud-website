require 'spec_helper'

describe Resource do
  #  pending "add some examples to (or delete) #{__FILE__}"

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

  subject { @resource }

  describe "validate attributes" do
    it { should respond_to(:name) }
    it { should respond_to(:owner) }
    it { should respond_to(:description) }
    it { should respond_to(:manufacturer) }
    it { should respond_to(:model) }
    it { should respond_to(:creation_date) }
    # it { should respond_to(:polling_freq) }
    # it { should respond_to(:type) }
    it { should respond_to(:data_overview) }
    it { should respond_to(:serial_num) }
    it { should respond_to(:make) }
    it { should respond_to(:location) }
    it { should respond_to(:uri) }
    it { should respond_to(:mirror_proxy) }
    # it { should respond_to(:tags) }
    # it { should respond_to(:active) }
    it { should be_valid }
  end

  describe "when name is not present" do
    before { @resource.name = " " }
    it { should_not be_valid }
  end

end
