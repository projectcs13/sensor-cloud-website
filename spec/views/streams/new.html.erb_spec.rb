require 'spec_helper'

describe "streams/new" do
  before(:each) do
    assign(:stream, stub_model(Stream,
      :description => "MyString",
      :user_id => 1
    ).as_new_record)
  end

  it "renders new stream form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", streams_path, "post" do
      assert_select "input#stream_description[name=?]", "stream[description]"
      assert_select "input#stream_user_id[name=?]", "stream[user_id]"
    end
  end
end
