require 'spec_helper'

describe "resources/show" do
  before(:each) do
    @resource = assign(:resource, stub_model(Resource,
      :owner => "Owner",
      :name => "Name",
      :description => "Description",
      :manufacturer => "Manufacturer",
      :model => "Model",
      :privacy => 1,
      :notes => "Notes",
      :update_freq => 2,
      :resource_type => "Resource Type"
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Owner/)
    rendered.should match(/Name/)
    rendered.should match(/Description/)
    rendered.should match(/Manufacturer/)
    rendered.should match(/Model/)
    rendered.should match(/1/)
    rendered.should match(/Notes/)
    rendered.should match(/2/)
    rendered.should match(/Resource Type/)
  end
end
