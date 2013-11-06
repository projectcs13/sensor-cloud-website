Her::API.setup url: "#{CONF['API_URL']}" do |c|
  c.use Faraday::Request::UrlEncoded
  c.use Her::Middleware::DefaultParseJSON
	# c.use ESParser
  c.use Faraday::Adapter::NetHttp
end
