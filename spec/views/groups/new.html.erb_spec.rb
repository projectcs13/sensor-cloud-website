require 'spec_helper'

describe "groups/new" do
  before(:each) do
    assign(:group, stub_model(Group,
      :owner => "MyString",
      :name => "MyString",
      :description => "MyString",
      :tags => "MyString",
      :input => "MyString",
      :output => "MyString",
      :private => false,
      :subscribers => 10,
      :user_ranking => 11
    ).as_new_record)
  end

  it "renders new group form" do
    render

    # Run the generator again with the --webrat flag if you want to use webrat matchers
    assert_select "form[action=?][method=?]", groups_path, "post" do
      assert_select "input#group_owner[name=?]", "group[owner]"
      assert_select "input#group_name[name=?]", "group[name]"
      assert_select "input#group_description[name=?]", "group[description]"
      assert_select "input#group_tags[name=?]", "group[tags]"
      assert_select "input#group_input[name=?]", "group[input]"
      assert_select "input#group_output[name=?]", "group[output]"
      assert_select "input#group_private[name=?]", "group[private]"
      assert_select "input#group_subscribers[name=?]", "group[subscribers]"
      assert_select "input#group_user_ranking[name=?]", "group[user_ranking]"
    end
  end
end
