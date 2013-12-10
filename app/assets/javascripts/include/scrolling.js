/**
* This function initializes the scrolling pagination functionalities and make work.
*
* @author: Li Hao,
* 
*/
var stream_count;
var user_count;
var waiting = false;

function add_new_content(page, content, type){
	if(waiting==true)
		return false;
  if(type=="stream"){
	   $.ajax({
  	   	type: "POST",
  		  url: "/get_more_info",
  		  data: { search: { page: stream_count, sort_by: $('#search_sort_by').val(), query: $('#search_query').val(), refresh: false}}
	   }).done(function( msg ) {
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
        waiting = false;
        user_count = user_count + 1;
     });
  }
}

function init_scrolling() {
  //get the current location
  stream_count = $('#streams ul.pagination li.active').index();
  user_count = $('#users ul.pagination li.active').index();
  if(stream_count==-1) stream_count=1;
  if(user_count==-1) user_count=1;

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

  add_new_content(user_count, pane2, "user");
  waiting = true;

  return false;	
}