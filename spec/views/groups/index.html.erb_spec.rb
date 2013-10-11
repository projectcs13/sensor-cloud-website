require 'spec_helper'

describe "groups/index" do
  before(:each) do
    assign(:groups, [
      stub_model(Group,
        :owner => "Owner",
        :name => "Name",
        :description => "Description",
        :tags => "Tags",
        :input => "Input",
        :output => "Output",
        :private => false,
        :subscribers => 10,
        :user_ranking => 11
      ),
      stub_model(Group,
        :owner => "Owner",
        :name => "Name",
        :description => "Description",
        :tags => "Tags",
        :input => "Input",
        :output => "Output",
        :private => false,
        :subscribers => 10,
        :user_ranking => 11
      )
    ])
  end

  it "renders a list of groups" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Owner".to_s, :count => 2
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => "Tags".to_s, :count => 2
    assert_select "tr>td", :text => "Input".to_s, :count => 2
    assert_select "tr>td", :text => "Output".to_s, :count => 2
    assert_select "tr>td", :text => false.to_s, :count => 2
    assert_select "tr>td", :text => 10.to_s, :count => 2
    assert_select "tr>td", :text => 11.to_s, :count => 2
  end
end
