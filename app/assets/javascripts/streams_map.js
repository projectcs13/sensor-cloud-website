/*
	this file contains the code to display the stream`s location on a google map

*/
var map;

function initialize(latitude, longtitude){
    			var mapOptions = {
    				center: new google.maps.LatLng(latitude, longtitude),
    				zoom: 8,
    				mapTypeId: google.maps.MapTypeId.ROADMAP
    			};
    			map = new google.maps.Map(document.getElementById("map-canvas"), mapOptions);
                
                var marker = new google.maps.Marker({
                    position: new google.maps.latLng(latitude, longtitude),
                    map: map,
                    title: 'sensor`s location'
                });
    		};

window.onload = function() {
    var height = $('#map-canvas').width();
    $('#map-canvas').css({'height':height, 'position':'relative', 'width':'100%'});
    //initialize();
}

