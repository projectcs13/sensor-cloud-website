/*
    This file includes functions for displaying a stream graph
    At the moment it's just dummy data but the basic idea is to append
    data to the graph selection in the form
    {data: [list-of-data-points] pdata: [list-of-predicted-datapoints]}
    and call the function for drawing the graph.

 */

function stream_graph(width) {
    var url = window.location.href.split("/");
    var stream_id = url[url.length - 1];
    var DATA_URL = "/vsdatapoints/"+stream_id;
    var P_DATA_URL = "/vsprediction/"+stream_id;
    var parseDate = d3.time.format("%Y-%m-%dT%H:%M:%S.%L").parse;
    var streamChart = timeChart();
        streamChart.width(width).height(200);
    var graph = d3.select("#graph-canvas");
    var data = [];
    var p_data = [];

    function draw_graph(){
        console.log("draw_graph");
        var graphData = {data:data,  pdata: p_data};
        graph
            .datum(graphData)
            .call(streamChart);
        }

    function fetch_data(){
        res = $.get(DATA_URL);
        res.done(function( result ) {
            result = result.data // parse the response
            data = result.reverse(); // data is coming in reverse order
            data.map(function(d){d.timestamp = parseDate(d.timestamp)});
            data.map(function(d){d.value = Number(d.value)});
            draw_graph();
        });
        res.fail(function (e, result) {
            console.log(e);
        });
    }

    this.draw_prediction_data = function(predictionData){
        var timeOrigin = data[data.length-1].timestamp;
        var timeDiff = timeOrigin - data[data.length-2].timestamp;
        var predictionOrigin = data[data.length-1];
            predictionOrigin['hi95'] = predictionOrigin.value;
            predictionOrigin['hi80'] = predictionOrigin.value;
            predictionOrigin['lo95'] = predictionOrigin.value;
            predictionOrigin['lo80'] = predictionOrigin.value;
        predictionData = predictionData.predictions; // parse the response
            console.log(predictionData);
            var i = 1;
            predictionData.map(function(d){
                d['timestamp'] = new Date(timeOrigin.getTime()+timeDiff*i);
                i += 1;
            });
            p_data = predictionData;
            p_data.unshift(predictionOrigin); // Add last real datapoint as an origin for the prediction data-set
            draw_graph();
    }

    this.fetch_prediction_data = function(){
        var timeOrigin = data[data.length-1].timestamp;
        var timeDiff = timeOrigin - data[data.length-2].timestamp;
        var predictionOrigin = data[data.length-1];
            predictionOrigin['hi95'] = predictionOrigin.value;
            predictionOrigin['hi80'] = predictionOrigin.value;
            predictionOrigin['lo95'] = predictionOrigin.value;
            predictionOrigin['lo80'] = predictionOrigin.value;

        res = $.get(P_DATA_URL);
        res.done(function( result ) {
            result = result.predictions; // parse the response
            console.log(result);
            var i = 1;
            result.map(function(d){
                d['timestamp'] = new Date(timeOrigin.getTime()+timeDiff*i);
                i += 1;
            });
            p_data = result;
            p_data.unshift(predictionOrigin); // Add last real datapoint as an origin for the prediction data-set
            draw_graph();
        });

        res.fail(function (e, result) {
            console.log(e);
        });

    }
    this.add_single_datapoint = function(datapoint){
        datapoint = JSON.parse(datapoint);
        var newDatapoint = {};
        newDatapoint['timestamp'] = parseDate(datapoint.timestamp);
        newDatapoint['value'] = Number(datapoint.value);
        data.push(newDatapoint);
        draw_graph();
    }

    this.init = function(){
    draw_graph();
    fetch_data();
    }
}


