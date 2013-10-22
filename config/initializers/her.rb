Her::API.setup url: "http://srv1.csproj13.student.it.uu.se:8000/" do |c|
  c.use Faraday::Request::UrlEncoded
  c.use Her::Middleware::DefaultParseJSON
  c.use Faraday::Adapter::NetHttp
end
