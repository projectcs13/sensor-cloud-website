window.createMap = (form) ->
  browserSupportFlag = false

  mapOptions = 
    center: new google.maps.LatLng 60, 18
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true

  map = new google.maps.Map form.find('#map-canvas')[0], mapOptions
  #Try W3C Geolocation (Preferred)
  if navigator.geolocation
    browserSupportFlag = true;
    navigator.geolocation.getCurrentPosition (position) ->
      initialLocation = new google.maps.LatLng position.coords.latitude, position.coords.longitude
      map.setCenter initialLocation
      placeMarker map, form, initialLocation
    ,() ->
      console.log "error"
      # Get GeoLocation from IP here
      #
      #
      placeMarker map, form, map.center
  #Browser doesn't support Geolocation
  else
    browserSupportFlag = false;
    # Get GeoLocation from IP here
    #
    #
    placeMarker map, form, map.center

placeMarker = (map, form, loc) ->
  marker = new google.maps.Marker
    map: map
    draggable: true
    animation: google.maps.Animation.DROP
    position: loc

  form.find('#lat').val marker.getPosition().lat()
  form.find('#lon').val marker.getPosition().lng()

  google.maps.event.addListener marker, "dragend", (evt) ->
    form.find('#lat').val evt.latLng.lat()
    form.find('#lon').val evt.latLng.lng()


