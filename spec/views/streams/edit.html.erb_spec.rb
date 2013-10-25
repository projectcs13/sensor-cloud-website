=begin

require 'spec_helper'

describe "streams/edit" do
  before(:each) do
    @stream = assign(:stream, stub_model(Stream,
      :name => "MyString",
      :description => "MyText",
      :private => 1,
      :deviation => 1.5,
      :longitude => 1.5,
      :latitude => 1.5,
      :type => "",
      :unit => "MyString",
      :bound_max => 1.5,
      :bound_min => 1.5,
      :state => 1,
      :ranking => 1,
      :notes => "MyText"
    ))
  end

  it "renders the edit stream form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", resource_stream_path(@stream), "post" do
      assert_select "input#stream_name[name=?]", "stream[name]"
      assert_select "textarea#stream_description[name=?]", "stream[description]"
      assert_select "input#stream_private[name=?]", "stream[private]"
      assert_select "input#stream_deviation[name=?]", "stream[deviation]"
      assert_select "input#stream_longitude[name=?]", "stream[longitude]"
      assert_select "input#stream_latitude[name=?]", "stream[latitude]"
      assert_select "input#stream_type[name=?]", "stream[type]"
      assert_select "input#stream_unit[name=?]", "stream[unit]"
      assert_select "input#stream_bound_max[name=?]", "stream[bound_max]"
      assert_select "input#stream_bound_min[name=?]", "stream[bound_min]"
      assert_select "input#stream_state[name=?]", "stream[state]"
      assert_select "input#stream_ranking[name=?]", "stream[ranking]"
      assert_select "textarea#stream_notes[name=?]", "stream[notes]"
    end
  end
end

=end
