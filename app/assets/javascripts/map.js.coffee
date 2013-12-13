window.createMap = (options) ->
  { dom, location, editable } = options

  #Try W3C Geolocation (Preferred)
  if location is null
    location = new google.maps.LatLng 60, 18
    if navigator.geolocation
      navigator.geolocation.getCurrentPosition (position) ->
        location = new google.maps.LatLng position.coords.latitude, position.coords.longitude
        setup dom, location, editable
      , ->
        console.log "error"
        # Get GeoLocation from IP here
        # location = getLocationByIP()
        setup dom, location, editable

    else #Browser doesn't support Geolocation
      # Get GeoLocation from IP here
      # location = getLocationByIP()
      setup dom, location, editable
  else
    location = new google.maps.LatLng location[0], location[1]
    setup dom, location, editable

getLocationByIP = () ->
  # nothing now

setup = (dom, location, editable) ->
  # Maximize Map Canvas Dimensions
  console.log dom
  console.log location
  console.log editable
  canvas = dom.find('#map-canvas')
  w = canvas.parent().width()
  h = canvas.parent().height()
  canvas.width(w).height(h)

  if !editable
    drag = false
  else
    drag = true

  mapOptions =
    center: location
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true

  map = new google.maps.Map canvas[0], mapOptions

  marker = new google.maps.Marker
    map: map
    draggable: drag
    animation: google.maps.Animation.DROP
    position: location

  dom.find('#lat').val marker.getPosition().lat()
  dom.find('#lon').val marker.getPosition().lng()

  if editable
    google.maps.event.addListener marker, "dragend", (evt) ->
      dom.find('#lat').val evt.latLng.lat()
      dom.find('#lon').val evt.latLng.lng()
