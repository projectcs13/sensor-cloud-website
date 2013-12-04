/**
* This function initializes the scrolling pagination functionalities and make work.
*
* @author: Li Hao,
* 
*/
var stream_count =1;
var user_count=1;
var waiting = false;

function add_new_stream_item(item, father){
	var stream_id = item._id;
	var stream_url = "/streams/" + stream_id;
	var stream_name = item._source.name;
	var stream_description = item._source.description;
	var stream_last_updated = item._source.last_updated;
	var stream_subscribers = item._source.subscribers;
	if(item._source.location == undefined) var stream_location = " "; else var stream_location = item._source.location;
	var scale = 5;
	var starcount = 0;
	var ranking = item._source.user_ranking.average / (100/scale);

	var item_pane = "<div class=\"panel panel-default search-result\" data-location=\""+stream_location+"\" data-streamid=\""+stream_id+"\">"
                +"<div class=\"panel-heading\"><a href="+stream_url+">"+stream_name+"</a></div>"
                +"<div class=\"panel-body\">"
                +"<span class=\"stream-description\">"+stream_description+"</span>"
                +"<span class=\"last-update\">Last updated "+stream_last_updated+" ago</span>"
                +"<div class=\"star-rating\">";
    var x = 0 ;
    for(x=0;x<ranking;x++){
    	item_pane = item_pane + "<span class=\"glyphicon glyphicon-star\"></span>";
    	starcount = starcount + 1;
    }
    if((ranking%scale) > (scale/2)){
    	item_pane = item_pane + "<span class=\"glyphicon glyphicon-star\"></span>";
    	starcount = starcount + 1;
    }
    for(x=0;x<(scale-starcount);x++){
    	item_pane = item_pane + "<span class=\"glyphicon glyphicon-star-empty\"></span>";
    }
    item_pane = item_pane + "</div></div></div>";

	father.append(item_pane);
}
function add_new_user_item(item, father){
  var user_id = item._source._id;
  var url = "/users/"+user_id;
  var user_name = item._source.username;
  var id = item._id;

  item_pane =  "<li class=\"search-result\">"
              +"<div class=\"row\">"
              +"<div class=\"col-md-9\">"
              +"<h4>"
              +"<span class=\"glyphicon glyphicon-stats\"></span>"
              +"<a href="+url+">"+user_name+"</a>"
              +"</div>"
              +"<div class=\"col-md-3 search-results-stats\">"
              +"<ul class=\"pull-right\">"
              +"</ul>"
              +"</div>"
              +"</div>"
              +"<p>"+id+"</p>"
              +"<span class=\"last-update\">Last updated "+"5 seconds"+" ago</span>"
              +"<br /><br />"
              +"</li>";
  father.append(item_pane);
}

function add_new_content(page, content, type){
	if(waiting==true)
		return false;
  if(type=="stream"){
	   $.ajax({
  	   	type: "POST",
  		  url: "/get_more_info",
  		  data: { search: { page: stream_count, sort_by: $('#search_sort_by').val(), query: $('#search_query').val(), refresh: false}}
	   }).done(function( msg ) {
      	for(var j=0;j<msg.length;j++)
          add_new_stream_item(msg[j], content);
    	  waiting = false;
    	  stream_count = stream_count + 1;
  	 });
  }
  else if(type=="user"){
    $.ajax({
        type: "POST",
        url: "/get_more_info",
        data: { search: { page_users: user_count, sort_by: $('#search_sort_by').val(), query: $('#search_query').val(), refresh: false}}
     }).done(function( msg ) {
        for(var j=0;j<msg.length;j++)
          add_new_user_item(msg[j], content);
        waiting = false;
        user_count = user_count + 1;
     });
  }
}

function init_scrolling() {

  var pane1 = $("#scroll-pane1");
  var pane2 = $("#scroll-pane2");

  pane1.scroll(function(){
    if($(this).scrollTop() + $(this).height() > $(this).prop('scrollHeight')-10 ) {
       add_new_content(stream_count, pane1, "stream");
       waiting = true;
   }
  });
  pane2.scroll(function(){
    if($(this).scrollTop() + $(this).height() > $(this).prop('scrollHeight')-10 ) {
       add_new_content(user_count, pane2, "user");
       waiting = true;
   }
  });

  return false;	
}