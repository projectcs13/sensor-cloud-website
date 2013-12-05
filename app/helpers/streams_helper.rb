module StreamsHelper
	def deleteall
		if current_user.username == params[:username]
			link_to 'Delete All Streams', streams_path, method: :delete, data: { confirm: 'Are you sure?' }, class: "glyphicon glyphicon-remove btn btn-danger right"
		end
	end	

	def deleteone
		if current_user.username == params[:username]
			link_to 'Delete', "streams/#{stream['id']}", method: :delete, data: { confirm: 'Are you sure?' }, class: "btn btn-sm btn-danger right glyphicon glyphicon-remove"
		end
	end	
	# def newstream
	# 	<%  if current_user.username == params[:username] %>
	# 		<div class="btn-group">
 #      			<button type="button" class="btn btn-primary">
 #        			<%= link_to 'New Stream', new_stream_path, class: "glyphicon glyphicon-plus" %>
 #      			</button>
 #      			<button type="button" class="btn btn-primary dropdown-toggle" data-toggle="dropdown">
 #        			<span class="caret"></span>
 #        			<span class="sr-only">Toggle Dropdown</span>
 #      			</button>
 #      			<ul class="dropdown-menu" role="menu">
 #        			<li>
 #          				<%= link_to "From resource", controller: "streams", action: "new_from_resource" %>
 #          				<%#= link_to "From resource", new_multistream_path %>
 #        			</li>
 #      			</ul>
 #    		</div>
	# 	end
	# end	
end
