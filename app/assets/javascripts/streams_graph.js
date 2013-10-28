/*
    This file includes functions for displaying a stream graph
    At the moment it's just dummy data but the basic idea is to append
    data to the graph selection in the form 
    {data: [list-of-data-points] pdata: [list-of-predicted-datapoints]}
    and call the function for drawing the graph.

 */

function show_graph() {
        var stream_chart = timeChart();

        var width = $("#stream-graph").width(); // Get width of div containing graph
        stream_chart.width(width)   // Set width and height attribute of the chart
                    .height(250);
        var graph = d3.select("#stream-graph");

        // Generate dummy data
        var dummy_data = [];
        var year = 2012;
        var parseDate = d3.time.format("%Y-%m-%d").parse;
        for (var i = 0; i <= 9; i++) {
                var newvalue = Math.random() * 2000;
                year += 2;
                var theDate = parseDate(year +"-12-12");
                dummy_data.push({value:newvalue, date: theDate});
            };
        var dummy_pdata = [];
        
        graph
            .datum({data: dummy_data, pdata: []}) // Append data to the graph
            .call(stream_chart);    // Call function to draw graph

        // Append last element of data to the predicted data to serve as
        // origin for prediction line and area
        var last_elem = dummy_data[dummy_data.length-1];
        dummy_pdata.unshift({value:last_elem.value, 
                             date: last_elem.date, 
                             hi95:last_elem.value, 
                             lo95:last_elem.value, 
                             hi80:last_elem.value, 
                             lo80:last_elem.value});

        // Interval to generate dummy prediction data
        setInterval(function(){
                var newvalue = Math.random() * 2000;
                var hi80 = newvalue + Math.random() * 400 + 100,
                    lo80 = newvalue - Math.random() * 400 - 100,
                    hi95 = hi80 + Math.random() * 400 + 100,
                    lo95 = lo80 - Math.random() * 400 - 100;
                year += 2;
                var theDate = parseDate(year +"-12-12");
                dummy_pdata.push({value:newvalue, 
                                  date: theDate, 
                                  hi95:hi95, 
                                  lo95:lo95, 
                                  hi80:hi80, 
                                  lo80:lo80});

                graph
                    .datum({data: dummy_data, pdata: dummy_pdata})
                    .call(stream_chart);
        }, 5000);
}

     