require 'json'

class Api

  # def self.retrieve_token_info access_token
  #   url = "/tokens/#{access_token}"
  #   make :get, url, nil, access_token
  # end

  def self.renew_access_token refresh_token
    client = "client_id=995342763478-fh8bd2u58n1tl98nmec5jrd76dkbeksq.apps.googleusercontent.com"
    secret = "&client_secret=fVpjWngIEny9VTf3ZPZr8Sh6"
    rtoken = "&refresh_token=#{refresh_token}"
    g_type = "&grant_type=refresh_token"
    body   = client + secret + rtoken + g_type

    res = connect.post do |req|
      req.url "https://accounts.google.com/o/oauth2/token"
      req.headers["Content-Type"] = "application/x-www-form-urlencoded"
      req.body = body
    end

    parse_JSON_response res
  end

  def self.authenticate
    connect.post("/users/_auth/").body
  end

  def self.get url, token
    make :get, url, nil, token
  end

  def self.post url, body, token
    make :post, url, body, token
  end

  def self.put url, body, token
    make :put, url, body, token
  end

  def self.delete url, body, token
    make :delete, url, body, token
  end

  private
    def self.connect
      conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
        faraday.request  :url_encoded             # form-encode POST params
        faraday.response :logger                  # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter  # make requests with Net::HTTP
      end
    end

    def self.make method, url, body, token
      token = "" unless token
      res = connect.send method do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.headers['Access-Token'] = token
        req.body = body.to_json if body
      end
      parsed = parse_JSON_response res
      puts parsed
      parsed
    end

    def self.parse_JSON_response res
      resp = res.to_hash
      resp[:body] = JSON.parse resp[:body]
      resp.stringify_keys!
    end

end
