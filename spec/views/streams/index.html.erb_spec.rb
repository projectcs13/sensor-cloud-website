=begin

require 'spec_helper'

describe "streams/index" do
  before(:each) do
    assign(:streams, [
      stub_model(Stream,
        :name => "Name",
        :description => "MyText",
        :private => 1,
        :deviation => 1.5,
        :longitude => 1.5,
        :latitude => 1.5,
        :type => "Type",
        :unit => "Unit",
        :bound_max => 1.5,
        :bound_min => 1.5,
        :state => 2,
        :ranking => 3,
        :notes => "MyText"
      ),
      stub_model(Stream,
        :name => "Name",
        :description => "MyText",
        :private => 1,
        :deviation => 1.5,
        :longitude => 1.5,
        :latitude => 1.5,
        :type => "Type",
        :unit => "Unit",
        :bound_max => 1.5,
        :bound_min => 1.5,
        :state => 2,
        :ranking => 3,
        :notes => "MyText"
      )
    ])
  end

  it "renders a list of streams" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Name".to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => "Type".to_s, :count => 2
    assert_select "tr>td", :text => "Unit".to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 1.5.to_s, :count => 2
    assert_select "tr>td", :text => 2.to_s, :count => 2
    assert_select "tr>td", :text => 3.to_s, :count => 2
    assert_select "tr>td", :text => "MyText".to_s, :count => 2
  end
end

=end
