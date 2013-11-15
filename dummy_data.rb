require 'faraday'
require 'json'
require 'yaml'

### Variables

@cid = 1 # Current User's id

CONF = YAML.load_file('config/config.yml')['development']


### Functions

def new_connection
  conn = Faraday.new(:url => "#{CONF['API_URL']}/users/#{@cid}/") do |faraday|
    faraday.request  :url_encoded             # form-encode POST params
    faraday.response :logger                  # log requests to STDOUT
    faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
  end
  conn
end

def send_data(method, url, json)
  conn = new_connection
  conn.send(method) do |req|
    req.url url
    req.headers['Content-Type'] = 'application/json'
    req.body = json
  end
end

def post_resource json
  url = "#{CONF['API_URL']}/resources/"
  send_data(:post, url, json)
end

def put_resource rid, json
  url = "#{CONF['API_URL']}/resources/" + rid
  send_data(:put, url, json)
end

def post_stream rid, json
  url = "#{CONF['API_URL']}/users/#{@cid}/resources/" + rid + "/streams/"
  send_data(:post, url, json)
end

def put_stream rid, sid, json
  url = "#{CONF['API_URL']}/users/#{@cid}/resources/" + rid + "/streams/" + sid
  send_data(:put, url, json)
end

def deleteResources
  url = "http://srv1.csproj13.student.it.uu.se:9200/sensorcloud/resource"
  send_data(:delete, url, nil)
end


### Generate data elements in ES

def generate_resources
  [
    {
      :name => "Weather Uppsala 1",
      :description => "Sensor which measures the weather in different places from Uppsala",
      :manufacturer => "Ericsson",
      :model => "ee80",
      # :make => "2",
      # :serial_num => "1234-ABCD-987",
      # :polling_freq => "60",
      # :data_overview => "data data data",
      # :location => "Uppsala, Sweden",
      # :uri => "http =>//sensors.ericsson.se",
      :tags => "temperature, weather, humidity, ericsson",
      :resource_type => "sensor",
      :active => "true",
      :user_id => @cid
    },

    {
      :name => "Weather Uppsala 2",
      :description => "Sensor which measures the weather in Uppsala",
      :manufacturer => "Ericsson",
      :model => "ef90",
      # :make => "2",
      # :serial_num => "5678-ABCD-987",
      # :polling_freq => "60",
      # :resource_type => "sensor",
      # :data_overview => "data data data",
      # :location => "Uppsala, Sweden",
      # :uri => "http =>//sensors.ericsson.se",
      :tags => "temperature, weather, humidity, ericsson",
      :resource_type => "sensor",
      :active => "true",
      :user_id => @cid
    },

    {
      :name => "Siemens si5",
      :description => "Sensor which measures the pollution",
      :manufacturer => "Siemens",
      :model => "s7",
      # :make => "1",
      # :serial_num => "1679-FGD-987",
      # :polling_freq => "60",
      # :resource_type => "sensor",
      # :data_overview => "data data data",
      # :location => "Stockholm, Sweden",
      # :uri => "http =>//sensors.siemens.se",
      :tags => "pollution, air, siemens",
      :resource_type => "sensor",
      :active => "true",
      :user_id => @cid
    }
  ]
end

def generate_streams
  [
    {
      :name => "Temperature",
      :description => "Uppsala Centrum",
      :accuracy => "70",
      :min_val => "-40",
      :max_val => "100",
      :longitude => "60",
      :latitude => "18",
      :stream_type => "temperature",
      :user_ranking => "20",
      :history_size => "100",
      :subscribers => "78",
      :tags => "temperature, uppsala, centrum",
      :active => "true",
      :private => "false"
    },

    {
      :name => "Temperature",
      :description => "Flogsta",
      :accuracy => "70",
      :min_val => "-40",
      :max_val => "100",
      :longitude => "60",
      :latitude => "18",
      :stream_type => "temperature",
      :user_ranking => "20",
      :history_size => "100",
      :subscribers => "78",
      :tags => "temperature, uppsala, centrum",
      :active => "true",
      :private => "true"
    },

    {
      :name => "Temperature",
      :description => "Kantorsgatan",
      :accuracy => "70",
      :min_val => "-40",
      :max_val => "100",
      :longitude => "60",
      :latitude => "18",
      :stream_type => "temperature",
      :user_ranking => "20",
      :history_size => "100",
      :subscribers => "78",
      :tags => "temperature, uppsala, kantorsgatan",
      :active => "false",
      :private => "false"
    },

    {
      :name => "Humidity",
      :description => "Uppsala Centrum",
      :accuracy => "100",
      :min_val => "0",
      :max_val => "100",
      :longitude => "60",
      :latitude => "18",
      :stream_type => "humidity",
      :user_ranking => "20",
      :history_size => "100",
      :subscribers => "56",
      :tags => "humidity, uppsala, centrum",
      :active => "true",
      :private => "false"
    },

    {
      :name => "Pollution",
      :description => "Engelska Park",
      :accuracy => "100",
      :min_val => "0",
      :max_val => "400",
      :longitude => "60",
      :latitude => "18",
      :stream_type => "pollution",
      :user_ranking => "20",
      :history_size => "100",
      :subscribers => "56",
      :tags => "pollution, engelska, park",
      :active => "true",
      :private => "false"
    },
  ]
end


def createResource number, streamsList
  resources = generate_resources
  streams = generate_streams

  r = resources[number]
  puts "JSON: #{r.to_json}"
  res = post_resource r.to_json
  puts "RES: #{res.body}"
  if res.status == 200
    streamsList.each do |sNumber|
      s = streams[sNumber]
      rid = JSON.parse(res.body)['_id']
      puts "RID: #{rid}"
      post_stream rid, s.to_json
    end
  end
end

# deleteResources
createResource 0, [0,1,2]
createResource 1, [0,3]
createResource 2, [4]
