require 'spec_helper'

describe "resources/new" do
  before(:each) do
    assign(:resource, stub_model(Resource,
      :owner => "MyString",
      :name => "MyString",
      :description => "MyString",
      :manufacturer => "MyString",
      :model => "MyString",
      :privacy => 1,
      :notes => "MyString",
      :update_freq => 1,
      :resource_type => "MyString"
    ).as_new_record)
  end

  it "renders new resource form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", resources_path, "post" do
      assert_select "input#resource_owner[name=?]", "resource[owner]"
      assert_select "input#resource_name[name=?]", "resource[name]"
      assert_select "input#resource_description[name=?]", "resource[description]"
      assert_select "input#resource_manufacturer[name=?]", "resource[manufacturer]"
      assert_select "input#resource_model[name=?]", "resource[model]"
      assert_select "input#resource_privacy[name=?]", "resource[privacy]"
      assert_select "input#resource_notes[name=?]", "resource[notes]"
      assert_select "input#resource_update_freq[name=?]", "resource[update_freq]"
      assert_select "input#resource_resource_type[name=?]", "resource[resource_type]"
    end
  end
end
