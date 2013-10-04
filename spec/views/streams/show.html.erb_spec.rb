=begin

require 'spec_helper'

describe "streams/show" do
  before(:each) do
    @stream = assign(:stream, stub_model(Stream,
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
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Name/)
    rendered.should match(/MyText/)
    rendered.should match(/1/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/Type/)
    rendered.should match(/Unit/)
    rendered.should match(/1.5/)
    rendered.should match(/1.5/)
    rendered.should match(/2/)
    rendered.should match(/3/)
    rendered.should match(/MyText/)
  end
end

=end
