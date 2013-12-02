Her::API.setup url: "#{CONF['API_URL']}" do |c|
  c.use Faraday::Request::UrlEncoded          # Request
  c.use Her::Middleware::DefaultParseJSON     # Response
  c.use Faraday::Adapter::NetHttp             # Adapter
end
