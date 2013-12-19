
window.selectStream = (event) ->
  multiGraph = window.multiGraph
  window.graphData = window.window.graphData
  stream_id = this.dataset.streamid
  iteration = this.dataset.iteration
  isSelected = $(this).children().hasClass("selected")
  selectedSpan = "<span class='pull-right glyphicon glyphicon-ok-sign selected" + iteration + "'></span>"
  noDataSpan = "<span class='pull-right no-data'>[NO DATA]</span>"
  panelHeader = $(this).children().first()

  if isSelected
    $(this).children().removeClass("selected")
    panelHeader.children().remove("span")
    window.window.graphData = window.graphData.filter (el) -> 
      return el.stream_id.toString() != stream_id
    $("#multiline-graph svg").remove()
    d3.select("#multiline-graph").datum(window.graphData).call(multiGraph)
  else
    $(this).children().addClass("selected")
    # ajax call
    res = $.get '/datapoints/' + stream_id

    res.done (result) ->
      result['stream_id'] = stream_id
      window.graphData.push result
      if result['data'].length == 0
        panelHeader.append(noDataSpan)
      else
        panelHeader.append(selectedSpan)
      $("#multiline-graph svg").remove()
      d3.select("#multiline-graph").datum(window.graphData).call(multiGraph)
    res.fail (e, data) ->
      console.log e

window.selectVStream = (event) ->
  stream_id = this.dataset.streamid
  iteration = this.dataset.iteration
  isSelected = $(this).children().hasClass("selected")
  selectedSpan = "<span class='pull-right glyphicon glyphicon-ok-sign selected" + iteration + "'></span>"
  noDataSpan = "<span class='pull-right no-data'>[NO DATA]</span>"
  panelHeader = $(this).children().first()

  if isSelected
    $(this).children().removeClass("selected")
    panelHeader.children().remove("span")
    window.graphData = window.graphData.filter (el) -> 
      return el.stream_id.toString() != stream_id
    $("#multiline-graph svg").remove()
    d3.select("#multiline-graph").datum(window.graphData).call(multiGraph)
  else
    $(this).children().addClass("selected")
    # ajax call
    res = $.get '/vsdatapoints/' + stream_id

    res.done (result) ->
      result['stream_id'] = stream_id
      window.graphData.push result
      if result['data'].length == 0
        panelHeader.append(noDataSpan)
      else
        panelHeader.append(selectedSpan)
      $("#multiline-graph svg").remove()
      d3.select("#multiline-graph").datum(window.graphData).call(multiGraph)
    res.fail (e, data) ->
      console.log e
