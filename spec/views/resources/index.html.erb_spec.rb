require 'spec_helper'

describe "resources/index" do
  before(:each) do
    assign(:resources, [
      stub_model(Resource,
        :owner => "Owner",
        :name => "Name",
        :description => "Description",
        :manufacturer => "Manufacturer",
        :model => "Model",
        :privacy => 1,
        :notes => "Notes",
        :update_freq => 2,
        :resource_type => "Resource Type"
      ),
      stub_model(Resource,
        :owner => "Owner",
        :name => "Name",
        :description => "Description",
        :manufacturer => "Manufacturer",
        :model => "Model",
        :privacy => 1,
        :notes => "Notes",
        :update_freq => 2,
        :resource_type => "Resource Type"
      )
    ])
  end

  it "renders a list of resources" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Owner".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Manufacturer".to_s, :count => 2
    assert_select "tr>td", :text => "Model".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => "Notes".to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => "Resource Type".to_s, :count => 2
  end
end
