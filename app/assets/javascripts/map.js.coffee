window.createMap = (options) ->
  { dom, location, editable } = options
  location = [60, 18] if location is null   # Default values

  # Maximize Map Canvas Dimensions
  canvas = dom.find('#map-canvas')
  w = canvas.parent().width()
  h = canvas.parent().height()
  canvas.width(w).height(h)

  mapOptions =
    center: new google.maps.LatLng location[0], location[1]
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true

  map = new google.maps.Map canvas[0], mapOptions

  marker = new google.maps.Marker
    map: map
    draggable: true
    animation: google.maps.Animation.DROP
    position: mapOptions.center

  dom.find('#lat').val marker.getPosition().lat()
  dom.find('#lon').val marker.getPosition().lng()

  if editable
    google.maps.event.addListener marker, "dragend", (evt) ->
      dom.find('#lat').val evt.latLng.lat()
      dom.find('#lon').val evt.latLng.lng()
