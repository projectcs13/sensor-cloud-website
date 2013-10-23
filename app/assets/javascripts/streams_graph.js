/*
    This file includes functions for displaying a stream graph

 */

window.onload = function() {
        var dummy_data = [];
        for (var i = 0; i <= 10; i++) {
                var newvalue = Math.random() * 3000;
                var year = 2012 + 2*i;
                dummy_data.push({value:newvalue, date: year +"-12-12"});
            };
        var parseDate = d3.time.format("%Y-%m-%d").parse;
        var testchart = timeChart()
                        .x(function(d) { return parseDate(d.date) })
                        .y(function(d) { return d.value});

        var width = $("#stream-graph").width(); // get width of div containing graph
        testchart.width(width)
                .height(200);

         d3.select("#stream-graph")
                .datum(dummy_data)
                .call(testchart);

        }
