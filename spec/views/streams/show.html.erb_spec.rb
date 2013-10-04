require 'spec_helper'

describe "streams/show" do
  before(:each) do
    @stream = assign(:stream, stub_model(Stream,
      :description => "Description",
      :user_id => 1
    ))
  end

  it "renders attributes in <p>" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    rendered.should match(/Description/)
    rendered.should match(/1/)
  end
end
