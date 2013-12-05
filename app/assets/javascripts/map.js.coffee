window.createMap = (form) ->
  mapOptions =
    center: new google.maps.LatLng 60, 18
    zoom: 8
    mapTypeId: google.maps.MapTypeId.ROADMAP
    disableDefaultUI: true

  map = new google.maps.Map form.find('#map-canvas')[0], mapOptions

  marker = new google.maps.Marker
    map: map
    draggable: true
    animation: google.maps.Animation.DROP
    position: mapOptions.center

  form.find('#lat').val marker.getPosition().lat()
  form.find('#lon').val marker.getPosition().lng()

  google.maps.event.addListener marker, "dragend", (evt) ->
    form.find('#lat').val evt.latLng.lat()
    form.find('#lon').val evt.latLng.lng()


