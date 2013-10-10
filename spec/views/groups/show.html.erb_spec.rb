require 'spec_helper'

describe "groups/show" do
  before(:each) do
    @group = assign(:group, stub_model(Group,
      :owner => "Owner",
      :name => "Name",
      :description => "Description",
      :tags => "Tags",
      :input => "Input",
      :output => "Output",
      :private => false,
      :subscribers => "",
      :user_ranking => ""
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Owner/)
    rendered.should match(/Name/)
    rendered.should match(/Description/)
    rendered.should match(/Tags/)
    rendered.should match(/Input/)
    rendered.should match(/Output/)
    rendered.should match(/false/)
    rendered.should match(//)
    rendered.should match(//)
  end
end
