/*
    This file includes functions for displaying a stream graph

 */

window.onload = function() {
        var dummy_data = [];
        var year = 2012;
        for (var i = 0; i <= 9; i++) {
                var newvalue = Math.random() * 2000;
                year += 2;
                dummy_data.push({value:newvalue, date: year +"-12-12"});
            };
        var dummy_pdata = [];
        for (var i = 0; i <= 5; i++) {
                var newvalue = Math.random() * 2000;
                var hi80 = newvalue + Math.random() * 500,
                    lo80 = newvalue - Math.random() * 500;
                    hi95 = hi80 + Math.random() * 500,
                    lo95 = lo80 - Math.random() * 500,
                year += 2;
                dummy_pdata.push({value:newvalue, date: year +"-12-12", hi95:hi95, lo95:lo95, hi80:hi80, lo80:lo80})
              
            };
        var parseDate = d3.time.format("%Y-%m-%d").parse;
        var testchart = timeChart()
                        .x(function(d) { return parseDate(d.date) })
                        .y(function(d) { return d.value});

        var width = $("#stream-graph").width(); // get width of div containing graph
        testchart.width(width)
                .height(200);

        var graph = d3.select("#stream-graph");
        
        graph.datum({data: dummy_data, pdata: dummy_pdata})
             .call(testchart);
}

     