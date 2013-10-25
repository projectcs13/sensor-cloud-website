require 'spec_helper'

describe Group do
  before do
    @group = Group.new(
          owner: "Owner",
          name: "Name",
          description: "Description",
          tags: "Tags",
          input: "Input",
          output: "Output",
          private: false,
          subscribers: 10,
          user_ranking: 11
      )
  end

  subject { @group }

  describe "validate attributes" do
    it { should respond_to(:name) }
    it { should respond_to(:owner) }
    it { should respond_to(:description) }
    it { should respond_to(:tags) }
    it { should respond_to(:input) }
    it { should respond_to(:output) }
    it { should respond_to(:private) }
    it { should respond_to(:subscribers) }
    it { should respond_to(:user_ranking) }

    it { should be_valid }
  end

  describe "when name is not present" do
    before { @group.name = " " }
    it { should_not be_valid }
  end

end
