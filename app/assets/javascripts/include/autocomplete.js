$(function() {
		$( "#search_query" ).autocomplete({
			source: function (request, response) {
				$.ajax({
					url: "/autocomplete",
					type: "GET",
					data: request,
					success: function (data) {
						response($.map(data, function (el) {
							return {
								value: el.text
							};
						}));
					}
				});
			},
  			
		})});