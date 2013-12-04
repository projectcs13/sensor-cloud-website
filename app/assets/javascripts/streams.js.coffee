# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://coffeescript.org/

#<%= javascript_include_tag "https://maps.googleapis.com/maps/api/js?key=AIzaSyABRtdICt5P5VLp9uHsFVC_ArfcyLp17BM&sensor=true" %>
//= require 'include/streams_graph.js'
//= require 'include/streams_map.js'
//= require 'include/timeChart.js'
//= require 'include/client.js'

$ ->
  $(document).bind "streams_index", (e, obj) =>
    showDetails = (event) ->
      el = $(this)
      el.find('.details').toggle(500)
      el.find('.show-details')
        .toggleClass('glyphicon-chevron-up')
        .toggleClass('glyphicon-chevron-down')

    $('body').on 'click', '.list-group-item', showDetails


  $(document).bind "streams_new", (e, obj) =>
    TIME = 250

    descriptions = [
      "First, tell us the basic information which might describe your stream"
      "Now, please fill in the fields below with the technical details of your new stream"
      "Finally, we need you to set up the format and the communication mechanism"
    ]

    stepLabel       = $ ".step-label"
    stepDescription = $ ".step-description"

    currentStep = 0
    steps = $ '.step'
    steps.each (i, step) ->
      $(step).css 'display', 'none' if i != 0

    # steps.first().removeClass('hidden');

    btnBack   = $ "#btn-back"
    btnNext   = $ "#btn-next"
    btnCreate = $ "#btn-create"
    btnSubmit = $ "#submit"

    polling = $ ".polling"

    progress = $ "#progress-bar"
    ratio = progress.parent().width() / steps.length
    # ratio = ratio + ratio / 10;

    updateStepInformation = ->
      stepLabel.text "Step #{currentStep+1}"
      stepDescription.text descriptions[ currentStep ]

    decreaseBar = ->
      w = progress.width()
      progress.width(w - ratio)

    increaseBar = ->
      w = progress.width()
      progress.width(w + ratio)

    back = (event) ->
      do event.preventDefault

      if currentStep > 0
        if currentStep is steps.length-1
          btnCreate.css 'display', 'none'
          btnNext.css 'display', 'inline-block'
          # btnNext.removeClass('btn-disabled').addClass('btn-primary')

        steps.eq(currentStep).hide TIME
        currentStep--
        steps.eq(currentStep).show TIME

        do decreaseBar
        do updateStepInformation

        if currentStep is 0
          btnBack.css 'display', 'none'


    next = (event) ->
      do event.preventDefault

      if currentStep < steps.length-1
        btnBack.css 'display', 'inline-block'

        steps.eq(currentStep).hide TIME
        currentStep++
        steps.eq(currentStep).show TIME

        do increaseBar
        do updateStepInformation

        if currentStep is steps.length-1
          btnCreate.css 'display', 'inline-block'
          btnNext.css 'display', 'none'


    create = (event) ->
      do event.preventDefault

      do increaseBar
      setTimeout ->
        btnSubmit.trigger 'click'
      , TIME * 2

      # $(window).animate ->
      #   do increaseBar
      #   btnSubmit.trigger 'submit'
      # , 400


    switchChanged = (event) ->
      do event.preventDefault
      polling.toggle TIME * 2


    btnNext.on 'click', next
    do btnBack.on('click', back).hide
    do btnCreate.on('click', create).hide
    do updateStepInformation

    $("#update-switch").on 'switch-change', switchChanged

    mapOptions =
      center: new google.maps.LatLng 60, 18
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    map = new google.maps.Map $('#map-canvas')[0], mapOptions

    marker = new google.maps.Marker
      map: map
      draggable: true
      animation: google.maps.Animation.DROP
      position: mapOptions.center

    $('#lat').val marker.getPosition().lat()
    $('#lon').val marker.getPosition().lng()

    google.maps.event.addListener marker, "dragend", (evt) ->
      $('#lat').val evt.latLng.lat()
      $('#lon').val evt.latLng.lng()

  $(document).bind "streams_new_from_resource", (e, obj) =>

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
        console.log "CleanUp"
        cleanUpDom()
        console.log "/CleanUp"
        
        pl = ui.item.payload
        text = pl.manufacturer
        text = text+" "+pl.model
        $("#resource_model").val(text)
        
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

    
  $(document).bind "streams_show", (e, obj) => #js only loaded on "show" action
    # Set up graph element
    graphWidth = $("#graph-canvas").width()
    window.graph_object = new stream_graph(graphWidth)
    graph_object.init()

    # Set up buttons
    $("#prediction-description").hide()

    $("#prediction-btn").on 'click', ->
      $("#prediction-description").show()
      graph_object.fetch_prediction_data()

    loc = document.getElementById('location').getAttribute('value').split ","



    mapOptions =
      center: new google.maps.LatLng loc[0], loc[1]
      zoom: 8
      mapTypeId: google.maps.MapTypeId.ROADMAP
      disableDefaultUI: true

    map = new google.maps.Map $('#map-canvas')[0], mapOptions

    marker = new google.maps.Marker
      map: map
      draggable: false
      animation: google.maps.Animation.DROP
      position: mapOptions.center

    $("#live-update-btn").on 'switch-change', (e, data) ->
      value = data.value
      alert value
      toggle value


  action = "streams_" + $("body").data("action")
  $.event.trigger action
