window.createMap = (options) ->
  { dom, location, editable } = options
  browserSupportFlag

  #Try W3C Geolocation (Preferred)
  if location is null
    location = new google.maps.LatLng 18, 60
    if navigator.geolocation
      browserSupportFlag = true
      navigator.geolocation.getCurrentPosition (position) ->
        location = new google.maps.LatLng position.coords.latitude, position.coords.longitude
        setup dom, location, editable
      ,() ->
        console.log "error"
        # Get GeoLocation from IP here
        #
        setup dom, location, editable
    #Browser doesn't support Geolocation
    else
      browserSupportFlag = false;
      # Get GeoLocation from IP here
      #
      setup dom, location, editable

setup = (dom, location, editable) ->
  # Maximize Map Canvas Dimensions
  canvas = dom.find('#map-canvas')
  w = canvas.parent().width()
  h = canvas.parent().height()
  canvas.width(w).height(h)

  mapOptions =
    center: location
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true

  map = new google.maps.Map canvas[0], mapOptions

  marker = new google.maps.Marker
    map: map
    draggable: true
    animation: google.maps.Animation.DROP
    position: location

  dom.find('#lat').val marker.getPosition().lat()
  dom.find('#lon').val marker.getPosition().lng()

  if editable
    google.maps.event.addListener marker, "dragend", (evt) ->
      dom.find('#lat').val evt.latLng.lat()
      dom.find('#lon').val evt.latLng.lng()
