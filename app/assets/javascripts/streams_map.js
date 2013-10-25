/*
	this file contains the code to display the stream`s location on a google map

*/
var map;

function initialize_map(latitude, longtitude){
    			var mapOptions = {
    				center: new google.maps.LatLng(latitude, longtitude),
    				zoom: 8,
    				mapTypeId: google.maps.MapTypeId.ROADMAP
    			};
    			map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
                
                var marker = new google.maps.Marker({
                    position: new google.maps.LatLng(latitude, longtitude),
                    map: map,
                    title: 'sensor`s location'
                });
    		};