# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/streams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/client.js'
//= require 'include/stream_graph.js'
//= require 'include/stream_graph_multiline.js'
//= require 'include/filter_map'
//= require 'include/selectStream'

$ ->
  $(document).bind "streams_index", (e, obj) =>
    #setup map and graph containers
    #height still statically set since height() needs to render page to calculate correctly
    contentWidth = $(".right-side-content").width()
    $('#map-canvas').width(contentWidth).height(500)
    window.multiGraph = streamGraphMultiLine().width(contentWidth).height(300)
    window.graphData = []
    d3.select("#multiline-graph").datum(graphData).call(multiGraph)
    #setup functions for populating graph

    window.setupButtons = ->
      $('.search-result').off "click", selectStream
      $('.search-result').on "click", selectStream

      $('input.star').rating()
      $('.star-rating').on 'click', ->
        obj =
          json:
            stream_id: $(this).attr('id')
            value: parseFloat($(this).children('a').text())
        res = $.ajax
          url: '/userranking'
          type: 'PUT'
          data: JSON.stringify obj
          contentType: "application/json",
          dataType: "json",
          success: (result, thing) ->
            console.log result, thing

    setupButtons()
    map_init($(".scroll-pane").children(), $(".search-result"), $("#map-canvas"), null, null, null)

  $(document).bind "streams_new", (e, obj) =>
    form = $ 'form'
    window.newStreamForm form
    window.createMap
      dom: form
      location: null
      editable: true

  $(document).bind "streams_new_from_resource", (e, obj) =>
    forms = $('#forms')
    streams = $('#streams')
    uuid = $('#resource_uuid')
    resource_model = $('#resource_model')
    selectedTemplates = 0

    $(window).on 'beforeunload', (event) ->
      cleanUpDom()
      undefined

    resource_model.bind "keydown", (event) ->
      event.preventDefault() if event.keyCode is $.ui.keyCode.TAB and $(this).data("ui-autocomplete").menu.active

    resource_model.autocomplete(
      minLength: 1

      source: (request, response) ->
        $.getJSON "/suggest/#{request.term}", response

      focus: ->
        # prevent value inserted on focus
        false

      select: (event, ui) ->
        cleanUpDom()

        pl = ui.item.payload
        text = pl.manufacturer
        text = text+" "+pl.model
        resource_model.val(text)
        resource_model.data 'id', pl.resource

        uuid.parent().parent().removeClass('hidden')

        fetchStreamsFromResource pl.resource
        streams.parent().removeClass('hidden')
        false

    ).data('ui-autocomplete')._renderItem = (ul, item) ->
      console.log item
      text = item.payload.manufacturer
      text = text+" "+item.payload.model
      $('<li>')
          .data('item.autocomplete', item)
          .append('<a>'+text+'</a>')
          .appendTo(ul);

    cleanUpDom = ->
      $('#streams').empty()
      template = $('#form-template').clone()
      forms.empty()
      forms.append template

    fetchStreamsFromResource = (id) ->
      res = $.get "/resources/#{id}"
      res.done listStreams


    listStreams = (json) ->
      for stream in json.streams_suggest
        dom = $(render stream)
        streams.append dom
        createForm stream

      $('body').on 'click', '.select-suggestion', ->
        div = $(this).parent().siblings('.form-control')
        console.log div
        if $(this).prop('checked') or $(this).hasClass('done')
          div.removeClass('inactive')
          selectedTemplates = selectedTemplates + 1
          if selectedTemplates == 1
            div.addClass('chosen')
            showForm div.parent().index()
        else
          div.addClass('inactive').removeClass 'chosen'
          hideForm div.parent().index()
          i = findNextStream()
          showForm i
          selectedTemplates = selectedTemplates - 1

      $('body').on 'click', '.stream .form-control', (event) ->
        stream = $(this).parent()
        input = stream.find('.select-suggestion')
        if input.prop("checked")
          streams.find('.form-control').removeClass('chosen')
          $(this).addClass('chosen')
          index = stream.index()
          showForm index

    render = (stream) ->
      """
        <li class="input-group stream">
          <span class="input-group-addon">
            <input class="select-suggestion" type="checkbox">
          </span>
          <div class="form-control inactive">
            <h4 class="left">#{stream.type}</h4>
            <div class="clearfix"></div>
          </div>
        </li>
      """
      #<img class="spinner hidden" src="/assets/ajax-loader.gif" />

    findNextStream = ->
      for s in streams.children()
        div = $(s).find('.form-control')
        if not div.hasClass('done') and not div.hasClass('inactive')
          div.addClass 'chosen'
          return div.parent().index()
      $('#btnFinished').removeClass('hidden')
      undefined

    createForm = (json) ->
      form = $('#form-template')
      clone = form.clone()
      # clone.append $("""<div class="btn btn-primary btn-create">Create a stream</div>""")
      form.parent().append clone
      for k, v of json
        clone.find("#stream_#{k}").val v
      clone.find("#stream_resource_type").val resource_model.data 'id'

      window.newStreamForm clone

      clone.on 'submit', ->
        clone.find("#stream_uuid").val uuid.val()
        cloneIndex = clone.index()-1
        console.log 'cloneIndex', cloneIndex
        hideForm cloneIndex
        s = streams.children().eq(cloneIndex)
        s.find('.form-control').removeClass('chosen').addClass 'done'
        s.find('.select-suggestion').prop('disabled', true)

        i = findNextStream()
        console.log 'findNextStream', i
        showForm i


    hideForm = (index) ->
      f = forms.children().eq index+1
      f.addClass 'hidden'

    showForm = (index) ->
      if index != undefined
        $('#btnFinished').addClass('hidden')

        console.log index
        f = forms.children().eq index+1
        #if f.hasClass 'hidden'
        forms.children().addClass('hidden')
        f.removeClass 'hidden'
        window.createMap
          dom: f
          location: null
          editable: true

  $(document).bind "streams_show", (e, obj) => #js only loaded on "show" action
    parseDate = d3.time.format("%Y-%m-%dT%H:%M:%S.%L").parse
    # Set up graph element
    graphWidth = $("#graph-canvas").width()
    newGraph = streamGraph().width(graphWidth).height(300)
    url = window.location.href.split("/")
    stream_id = url[url.length - 1]
    DATA_URL = "/datapoints/"+stream_id
    P_DATA_URL = "/prediction/"+stream_id
    res = $.get DATA_URL
    graphData = {'data':[], 'pdata':[]}
    res.done (result) ->
      graphData['data'] = result.data
      d3.select("#graph-canvas").data([graphData]).call(newGraph)

    window.draw_prediction_data = (p_data) ->
      graphData['pdata'] = p_data.predictions
      # give all the prediction-data timestamps
      # this should be done in the back-end in the future
      last_time_stamp = graphData['data'][0].timestamp
      last_time_stamp2 = graphData['data'][1].timestamp
      time_difference = last_time_stamp-last_time_stamp2
      prediction_origin = graphData['data'][0]
      prediction_origin['hi95'] = prediction_origin.value
      prediction_origin['lo95'] = prediction_origin.value
      prediction_origin['hi80'] = prediction_origin.value
      prediction_origin['lo80'] = prediction_origin.value
      for d in graphData['pdata']
        tempTime = new Date(last_time_stamp.getTime() + time_difference)
        d['timestamp'] = tempTime
        last_time_stamp = tempTime
      graphData['pdata'].unshift(prediction_origin)
      console.log['pdata']
      newGraph.update()

    window.add_single_datapoint = (datapoint) ->
      datapoint = JSON.parse(datapoint)
      graphData.data.unshift(datapoint)
      graphData.data.pop()
      newGraph.update()
    # Set up buttons
    $("#prediction-description").hide()

    $("#prediction-btn").on 'click', ->
      $("#prediction-description").show()

    $('input.star').rating()
    $('.star-rating').on 'click', ->
      obj =
        json:
          stream_id: $(this).attr('id')
          value: parseFloat($(this).children('a').text())
      res = $.ajax
        url: '/userranking'
        type: 'PUT'
        data: JSON.stringify obj
        contentType: "application/json",
        dataType: "json",
        success: (result, thing) ->
          console.log result, thing


    loc = document.getElementById('location').getAttribute('value').split ","
    console.log loc[0]
    console.log loc[1]

    window.createMap
      dom: $('#map-canvas').parent()
      location: loc
      editable: false


    $("#live-update-btn").on 'switch-change', (e, data) ->
      value = data.value
      toggle value


  $(document).bind "streams_edit", (e, obj) =>
    form = $ 'form'
    loc = [$('#lat').val(), $('#lon').val()]
    window.newStreamForm form
    window.createMap
      dom: form
      location: loc
      editable: true


  body = $('body')
  cont = body.data('controller')
  meth = body.data('action')
  event = "#{cont}_#{meth}"
  $.event.trigger event
