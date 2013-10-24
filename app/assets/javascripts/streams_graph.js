/*
    This file includes functions for displaying a stream graph

 */

window.onload = function() {
        var dummy_data = [];
        var year = 2012;
        for (var i = 0; i <= 10; i++) {
                var newvalue = Math.random() * 3000;
                year += 2*i;
                dummy_data.push({value:newvalue, date: year +"-12-12"});
            };
        var predicted_data = [];
        for (var i = 0; i <= 3; i++) {
                var newvalue = Math.random() * 3000;
                year += 2*i;
                predicted_data.push({value:newvalue, date: year +"-12-12"});
            };
        var parseDate = d3.time.format("%Y-%m-%d").parse;
        var testchart = timeChart()
                        .x(function(d) { return parseDate(d.date) })
                        .y(function(d) { return d.value});

        var width = $("#stream-graph").width(); // get width of div containing graph
        testchart.width(width)
                .height(200);

        var graph = d3.select("#stream-graph");
        
        graph.datum({data: dummy_data, pdata: predicted_data})
             .call(testchart);

        $("#update").on("click", function() {
            year += 2;
            dummy_data.push({value:Math.random()*3000, date:year+"-12-12"});
            graph.datum(dummy_data).call(testchart);
            });
        }

     