$ -> 
	$("#trigger_function").change(->
	  selectedOption = ""
	  inputFields = ""

	  $("#trigger_function option:selected").each ->
	    selectedOption = $(this).text()

	  if selectedOption is "span"
	    inputFields = """ <div class='form-group'>
	  											<label for='trigger_min'>Min</label>
	  											<input id='trigger_min' name='trigger[min]' type='text' class='form-control'>
	  										</div>
	  										<div class='form-group'>
	  											<label for='trigger_max'>Max</label>
	  											<input id='trigger_max' name='trigger[max]' type='text' class='form-control'>
	  										</div> """
	  else
	    inputFields = """ <div class='form-group'>
	  											<label for='trigger_input'>Input</label>
	  											<input id='trigger_input' name='trigger[input]' type='text' class='form-control'>
	  										</div> """

	  $("#input-fields").html inputFields
	).change()

	$("#trigger_uri_enable").change(->
		uriField = "";
		if $(this).prop('checked')
			uriField = """
				<div class="form-group">
					<label for="trigger_uri">URI</label>
					<input id="trigger_uri" name="trigger[uri]" type="text" class="form-control">
				</div>"""
		$("#uri-field").html uriField
	).change()

	$("#trigger_stream_enable").change(->
		triggerOn = "";
		if $(this).prop('checked')
			triggerOn = """
					<label for="trigger_streams">Streams</label>
					<select class="form-control" id="trigger_streams" name="trigger[streams]"><option value="85r_hMK_Q4mWayewfDHCUw">kassadin's stream #1</option></select>
					"""
		else
			triggerOn = """
					<label for="trigger_vstreams">Virtual streams</label>
					<select class="form-control" id="trigger_vstreams" name="trigger[vstreams]"><option value="V8UkuMQITUGfDgyzkvVorw">qweqwe</option></select>
					"""
		$("#trigger-on").html triggerOn
	).change()