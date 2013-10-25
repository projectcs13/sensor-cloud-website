class ESParser < Faraday::Response::Middleware
	  def on_complete(env)
			    json = MultiJson.load(env[:body], symbolize_keys: true)
			    env[:body] = {
			        data: json[:_source],
			        errors: json[:errors],
			        metadata: json[:metadata]
			    }
					puts "ENV!!!!!!!!! #{env[:body]}"
	  end
end
