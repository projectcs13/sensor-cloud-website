require 'spec_helper'

describe "streams/edit" do
  before(:each) do
    @stream = assign(:stream, stub_model(Stream,
      :description => "MyString",
      :user_id => 1
    ))
  end

  it "renders the edit stream form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", stream_path(@stream), "post" do
      assert_select "input#stream_description[name=?]", "stream[description]"
      assert_select "input#stream_user_id[name=?]", "stream[user_id]"
    end
  end
end
