/**
* This function initializes the scrolling pagination functionalities and make work.
*
* @author: Li Hao,
* 
*/

var page_number = 1;
var waiting = true;
function init_scrolling() {
  $("#scroll-pane1").scroll(function(){
    if($(this).scrollTop() + $(this).height() > $(this).prop('scrollHeight')-10 && waiting) {
      waiting = false;
      var data = $('#search-bar').serializeArray();
          data.push({name: 'search[page]', value: page_number});
      var res = $.post('/get_more_info', data);
          res.complete(function() {
            waiting = true;
            page_number = page_number + 1;
          });
   }
  });
}