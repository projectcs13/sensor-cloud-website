//= require 'include/search_graph'

$ ->
	graphWidth = $(".search-graph").width()
	#console.log graphWidth
	search_graph = searchGraph().width(graphWidth)
	search_params = "?stream_id="
	for graph in $(".search-graph")
		search_params += graph.dataset.stream + ','
	search_params = search_params.slice(0, search_params.length-1)
	res = $.get '/history' + search_params
	res.done (result) ->
		datalist = result.history
		for graph in datalist
			d3.select(".search-graph#id"+graph.stream_id).datum(graph.data).call(search_graph)
		
	res.fail (e, data) ->
		console.log e

	#search_graph = searchGraph()
	#d3.selectAll(".search-graph").data(dummy_datasets).call(search_graph)