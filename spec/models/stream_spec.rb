require 'spec_helper'

describe Stream do
  before do
  	@stream = Stream.new(
  	name: "Example Stream",
    description: "Example",
    private: "true",
    accuracy: "1.2",
    longitude: "0.0",
    latitude: "0.0",
    stream_type: "Temperature",
    unit: "C",
    max_val: "100",
    min_val: "100",
    active: "true",
    tags: "Example",
    resource_id: 1,
    user_ranking: 5.0,
    history_size: 120,
    subscribers: 120,
    )
  end

  subject{ @stream }
  it { should respond_to(:name) }
  it { should respond_to(:description) }
  it { should respond_to(:private) }
  it { should respond_to(:accuracy) }
  it { should respond_to(:longitude) }
  it { should respond_to(:latitude) }

end
