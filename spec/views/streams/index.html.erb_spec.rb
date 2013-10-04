=begin

require 'spec_helper'

describe "streams/index" do
  before(:each) do
    assign(:streams, [
      stub_model(Stream,
        :description => "Description",
        :user_id => 1
      ),
      stub_model(Stream,
        :description => "Description",
        :user_id => 1
      )
    ])
  end

  it "renders a list of streams" do
    render
    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "tr>td", :text => "Description".to_s, :count => 2
    assert_select "tr>td", :text => 1.to_s, :count => 2
  end
end

=end
