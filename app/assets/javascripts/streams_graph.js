/*
    This file includes functions for displaying a stream graph
    At the moment it's just dummy data but the basic idea is to append
    data to the graph selection in the form 
    {data: [list-of-data-points] pdata: [list-of-predicted-datapoints]}
    and call the function for drawing the graph.

 */

function show_graph(stream_id) {
    var DATA_URL = "/datapoints/"+stream_id;
    var P_DATA_URL = "/prediction/"+stream_id;
    var width = $("#stream-graph").width();
    var parse_date = d3.time.format("%Y%m%dT%H%M%S.%L0").parse;
    var stream_chart = timeChart();
        stream_chart.width(width).height(200);
    var graph = d3.select("#stream-graph");
    var data = [];
    var p_data = [];
    $("#live-update-btn").on('switch-change', function (e, data) {
        var value = data.value;
        toggle(value);
        });
    
    $("#prediction-btn").on('click', function (e, data){
        fetch_prediction_data();
    });

    function draw_graph(){
        var s_data = {data:data,  pdata: p_data};
        graph
            .datum(s_data)
            .call(stream_chart);
        }

    function fetch_data(){
        $.get(DATA_URL, function( result ) {     
            result = result.hits //parse the response
            console.log(result);
            var jsonstr = JSON.stringify(result);

            // HERE you do the transform
            var new_jsonstr = jsonstr.split("timestamp").join("date");

            // You probably want to parse the altered string later
            var new_obj = JSON.parse(new_jsonstr);
            data = new_obj;
            data.map(function(d){d.date = parse_date(d.date)});
            console.log(data);
            draw_graph();
        });
    }

    function fetch_prediction_data(){
        var time_origin = data[data.length-1].date;
       console.log("hello");
        var time_diff = time_origin - data[data.length-2].date;
        
        res = $.get(P_DATA_URL);
        res.done(function( result ) {
            console.log("helloooo!?");
            result = result.predictions;
            console.log(result);
            var i = 0;
            result.map(function(d){ 
                d['date'] = "test";
                //new Date(time_origin.getTime()+time_diff*i);
                //i += 1;
            });
            console.log(result);
            p_data = result;
            draw_graph();
        });
        res.fail(function (e, result) {
            //result = result.predictions;
            
            console.log(e);
        });

    }

    function add_single_datapoint(datapoint){

    }
    // function timestepInterval() {
    //     var origin_date =  data[data.length-1]
    //     var interval = origin_date - data[data.length-2]    
    draw_graph();
    fetch_data();
}

     