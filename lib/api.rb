require 'json'

class Api

  def self.authenticate
    connect.post("/users/_auth/").body
  end

  def semantics_get url
    res = connect.get url
    resp = res.to_hash
    File.open("/home/iakovosk/semantics_output.txt", 'w') {|f| f.write(resp[:body]) }
    resp.stringify_keys!
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
    make :delete, url, body, tokendata["access_token"] = session[:token].access_token
  end

  private
    def self.make method, url, body, token
      # puts "token"
      # puts token["access_token"]
      res = request method, url, body, token[:access_token]

      parsed = parse_JSON_response res
      if parsed['status'] == 498   # Token not valid
        new_access_token = renew_access_token token

        res = request method, url, body, new_access_token
        parsed = parse_JSON_response res
        parsed["new_access_token"] = new_access_token
      end

      parsed
    end

    def self.request method, url, body, acc_token
      acc_token = "" unless acc_token
      connect.send method do |req|
        req.url url
        req.headers['Content-Type'] = 'application/json'
        req.headers['Access-Token'] = acc_token
        req.body = body.to_json if body
      end
    end

    def self.connect
      conn = Faraday.new(:url => "#{CONF['API_URL']}") do |faraday|
        faraday.request  :url_encoded               # form-encode POST params
        faraday.response :logger                    # log requests to STDOUT
        faraday.adapter  Faraday.default_adapter    # make requests with Net::HTTP
      end
    end

    def self.renew_access_token token
      res = connect.post do |req|
        req.url "http://localhost:8000/users/_renewtoken"
        req.headers["Refresh-Token"] = token[:refresh_token]
        req.headers["Username"]      = token[:username]
      end
      parsed = parse_JSON_response res
      parsed["body"]["access_token"]
    end

    def self.parse_JSON_response res
      resp = res.to_hash
      resp[:body] = JSON.parse resp[:body]
      resp.stringify_keys!
    end
end
