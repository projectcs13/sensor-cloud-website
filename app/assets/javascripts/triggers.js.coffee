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