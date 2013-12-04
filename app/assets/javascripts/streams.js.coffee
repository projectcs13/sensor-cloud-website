# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/streams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/timeChart.js'
//= require 'include/client.js'

$ ->
  $(document).bind "streams_new_from_resource", (e, obj) => # js only loaded on "streams_new_from_resource" action
    $("#resource_model").bind "keydown", (event) ->
      event.preventDefault() if event.keyCode is $.ui.keyCode.TAB and $(this).data("ui-autocomplete").menu.active

    $("#resource_model").autocomplete(
      minLength: 1

      source: (request, response) ->
        $.getJSON "/suggest/#{request.term}", response

      focus: ->
        # prevent value inserted on focus
        false

      select: (event, ui) ->
        pl = ui.item.payload
        text = pl.manufacturer
        text = text+" "+pl.model
        $("#resource_model").val(text)
        console.log "CleanUp"
        cleanUpDom()
        console.log "/CleanUp"
        fetchStreamsFromResource pl.resource
        false

    ).data('ui-autocomplete')._renderItem = (ul, item) ->
      console.log item
      text = item.payload.manufacturer
      text = text+" "+item.payload.model
      $('<li>')
          .data('item.autocomplete', item)
          .append('<a>'+text+'</a>')
          .appendTo(ul);

    cleanUpDom = () ->
      streams = $('#streams')
      ids = streams.children().each ->
        console.log $(this).data 'id'
      streams.empty()

    fetchStreamsFromResource = (id) ->
      res = $.get "/resources/#{id}"
      res.done listStreams

    listStreams = (json) ->
      console.log json
      place = $('#streams')

      for stream in json.streams_suggest
        dom = $(render stream)
        dom.data 'json', stream
        place.append dom

      $('body').on 'click', '.select-suggestion', (event) ->
        event.stopPropagation()
        if $(this).hasClass('input-group-addon')
          checkbox = $(this).find('.select-suggestion')
          checkbox.attr("checked", !checkbox.attr("checked"))
        else
          checkbox = $(this)
        stream = checkbox.parents('.stream')

        console.log checkbox[0].checked
        if checkbox[0].checked == false
          #ID created in ES, needs cleanup
          id = stream.data 'id'
          removeForm id
          res = $.ajax
            type: "DELETE"
            url: "/streams/#{id}"
            dataType: "json"

          res.done (data) ->
            console.log data

        else
          # Create ID (and store)
          checkbox.addClass('hidden')
          spinner = checkbox.siblings('.spinner')
          spinner.removeClass('hidden')

          json = {"stream" : stream.data 'json' }
          res = $.ajax
            type: "POST"
            url: "/streams"
            data: json
            dataType: "json"

          res.done (data) ->
            console.log data
            stream.data 'id', data.id
            checkbox.removeClass('hidden')
            spinner.addClass('hidden')
            createForm data.id

          res.fail (xhr, result) ->
            # Block checkbox? BIG RED TEXT?
            alert "Error: Redirection not working properly\n Response from server: #{result}"

    render = (stream) ->
      """
        <li class="input-group stream">
          <span class="input-group-addon">
            <img class="spinner hidden" src="/assets/ajax-loader.gif" />
            <input class="select-suggestion" type="checkbox">
          </span>
          <div class="form-control">
            <h4 class="left">#{stream.type}</h4>
            <div class="clearfix"></div>
            <h6 class="left">Description:</h6>
            <div class="clearfix"></div>
            <p class="left">#{stream.description}</p>
            <div class="clearfix"></div>
          </div>
        </li>
      """

    createForm = (id) ->
      form = $('#edit_stream_REPLACE_THIS_ID')
      clone = form.clone()
      form.parent().append clone
      clone.attr('id', "edit_stream_#{id}")
      clone.attr('action', "/streams/#{id}")
      clone.removeClass('hidden')

    removeForm = (id) ->
      form = $("#edit_stream_#{id}")
      console.log form
      form.remove()

    
  showDetails = (event) ->
    el = $(this)
    el.find('.details').toggle(500)
    el.find('.show-details')
      .toggleClass('glyphicon-chevron-up')
      .toggleClass('glyphicon-chevron-down')
  $('body').on 'click', '.list-group-item', showDetails


  $(document).bind "streams_show", (e, obj) => #js only loaded on "show" action
    # Set up graph element
    graphWidth = $("#graph-canvas").width();
    window.graph_object = new stream_graph(graphWidth);
    graph_object.init();

    # Set up buttons
    $("#prediction-description").hide();

    $("#prediction-btn").on 'click', ->
      $("#prediction-description").show()
      graph_object.fetch_prediction_data()

    loc = document.getElementById('location').getAttribute('value').split ","

    mapDiv = document.getElementById('map-canvas')

    mapOptions =
      center: new google.maps.LatLng loc[0], loc[1]
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    map = new google.maps.Map $('#map-canvas')[0], mapOptions

    marker = new google.maps.Marker
      map: map
      draggable:false
      animation: google.maps.Animation.DROP
      position: mapOptions.center

    $("#live-update-btn").on 'switch-change', (e, data) ->
      value = data.value
      alert value
      toggle(value)
  $(document).bind 'streams_new', (e,obj) =>
    mapDiv = document.getElementById('map-canvas')

    mapOptions =
      center: new google.maps.LatLng 60, 18
      zoom: 8,
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    map = new google.maps.Map $('#map-canvas')[0], mapOptions

    marker = new google.maps.Marker
      map: map
      draggable:true
      animation: google.maps.Animation.DROP
      position: mapOptions.center

    google.maps.event.addListener marker, "dragend", (evt) ->
      $('#lat').val(evt.latLng.lat())
      $('#lon').val(evt.latLng.lng())

  action = "streams_" + $("body").data("action")
  $.event.trigger action

