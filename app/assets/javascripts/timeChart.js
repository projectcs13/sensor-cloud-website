/**
* This function returns a function for visualising a chart using d3.js
* The parameters used for visualizing are defined in the closure returned
* and can be manipulated through getters and setters.
*
* @author: Mårten Blomberg, inspired by Mike Bostock (http://bost.ocks.org/mike/chart/time-series-chart.js)
*
* Example usage:
* 
* Configuring the chart:
*
* var chart = timechart() // assign closure to chart variable
*
* Some properties in the closure containing chart can be accesed
* using the getter/setter functions 
* chart.height // height of the chart (int)
* chart.width // width of the chart (int)
* chart.margin // margin of the chart (object e.g {top: right: bottom: left:})
* chart.x // function for parsing the x-value from the data
* chart.y // function for parsing the y-value from the data (the function should return a date object)
* 
* 
* Displaying the chart:
* d3.select("#chart") // select DOM element with id chart
*       .datum(data)  // append data to the d3 selection
*       .call(chart); // call the chart function with the selection and data
*
*/
function timeChart() {
  var margin = {top: 40, right: 20, bottom: 20, left: 50},
      parseDate = d3.time.format("%Y-%m-%d").parse;
      width = 760,
      height = 120,
      unit = "",
      xValue = function(d) { return d.date; },
      yValue = function(d) { return d.value; },
      xScale = d3.time.scale(),
      yScale = d3.scale.linear(),
      xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(6, 0),
      yAxis = d3.svg.axis().scale(yScale).orient("left").tickSize(10).ticks(5),
      //area = d3.svg.area().x(X).y(Y).interpolate("monotone"),
      line = d3.svg.line().x(X).y(Y),
      p_area_95 = d3.svg.area().x(X).y0(function(d){return yScale(d.lo95)}).y1(function(d){return yScale(d.hi95)});
      p_area_80 = d3.svg.area().x(X).y0(function(d){return yScale(d.lo80)}).y1(function(d){return yScale(d.hi80)});


  function chart(selection) {
    selection.each(function(data) {
      // Convert data to standard representation greedily;
      // this is needed for nondeterministic accessors.
      var pdata = data.pdata;
      data = data.data;
      pdata.map(function(d, i) {
        d.date = parseDate(d.date);
      });
      data.map(function(d, i) {
        d.date = parseDate(d.date);
      });

      var alldata = [].concat(data, pdata);
      var last_point = data[data.length-1];
      var dummy_origin = {value:last_point.value, hi95:last_point.value, lo95:last_point.value, hi80:last_point.value, lo80:last_point.value, date:last_point.date};
      pdata = [].concat(dummy_origin, pdata);
      // Update the x-scale.
      xScale
          .domain(d3.extent(alldata, function(d) { return d.date; }))
          .range([0, width - margin.left - margin.right]);

      // Update the y-scale.
      yScale
          .domain([d3.min(alldata, function(d) { return Math.min(d.value, d.lo95, d.lo80); }), 
                   d3.max(alldata, function(d) { return Math.max(d.value, d.hi95, d.hi80); })])
          .range([height - margin.top - margin.bottom, 0]);

      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([1]);
      

      // Otherwise, create the skeletal chart.
      var gEnter = svg.enter().append("svg").append("g");
        //gEnter.append("path").attr("class", "area");
        gEnter.append("path").attr("class", "line");
        gEnter.append("path").attr("class", "area p-area-95");
        gEnter.append("path").attr("class", "area p-area-80");
        gEnter.append("path").attr("class", "area p-line");
        gEnter.append("path").attr("class", "p-area80");
        gEnter.append("line").attr("class", "delimiter");
        gEnter.append("g").attr("class", "x axis");
        gEnter.append("g").attr("class", "y axis");
        gEnter.append("g").attr("class", "datapoints");
        gEnter.append("g").attr("class", "p-datapoints");
      
      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height);

      // Update the inner dimensions.
      var g = svg.select("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      // Update area for prediction with 95% confidence interval
      g.select(".p-area-95")
            .attr("d", p_area_95(pdata));
      // Update area for prediction with 80% confidence interval
      g.select(".p-area-80")
            .attr("d", p_area_80(pdata));
      // Update the line path.
      g.select(".line")
          .attr("d", line(data));

      g.select(".p-line")
          .attr("d", line(pdata));

      // Update the x-axis.
      g.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis);

      g.select(".y.axis")
          .attr("transform", "translate(0," + xScale.range()[0] + ")")
          .call(yAxis);

      // Select all datapoints if they exist
      var datapoints = g.select(".datapoints").selectAll("circle")
                        .data(data, function(d){return d.date});

      // Add datapoints that don't exist
      datapoints
          .enter()
          .append("circle")
          .attr("cx", function(d) {return X(d)})
          .attr("cy", function(d) {return Y(d)})
          .attr("r", 4)
          //.attr("class", "datapoint")
          .append("title")
          .text( function(d) {return d.value});
      
      // Update the datapoints
      datapoints
          .attr("cx", function(d) {return X(d)})
          .attr("cy", function(d) {return Y(d)});

      datapoints
        .exit()
        .remove()

      var delimiter= pdata.shift();

      d3.select(".delimiter")
        .attr("x1", xScale(delimiter.date))
        .attr("y1", yScale.range()[0])
        .attr("x2", xScale(delimiter.date))
        .attr("y2", yScale.range()[1])

      var pdatapoints = g.select(".p-datapoints").selectAll("circle")
                        .data(pdata, function(d){return d.date});

      // Add pdatapoints that don't exist
      pdatapoints
          .enter()
          .append("circle")
          .attr("cx", function(d) {return xScale(d.date)})
          .attr("cy", function(d) {return yScale(d.value)})
          .attr("r", 4)
          //.attr("class", "datapoint")
          .append("title")
          .text( function(d) {return d.value});
      
      // Update the pdatapoints
      pdatapoints
          .attr("cx", function(d) {return xScale(d.date)})
          .attr("cy", function(d) {return yScale(d.value)});

      pdatapoints
        .exit()
        .remove()

    });
  }

  // The x-accessor for the path generator; xScale xValue.
  function X(d) {
    return xScale(d.date);
  }

  // The x-accessor for the path generator; yScale yValue.
  function Y(d) {
    return yScale(d.value);
  }

  chart.margin = function(_) {
    if (!arguments.length) return margin;
    margin = _;
    return chart;
  };

  chart.width = function(_) {
    if (!arguments.length) return width;
    width = _;
    return chart;
  };

  chart.height = function(_) {
    if (!arguments.length) return height;
    height = _;
    return chart;
  };

  chart.x = function(_) {
    if (!arguments.length) return xValue;
    xValue = _;
    return chart;
  };

  chart.y = function(_) {
    if (!arguments.length) return yValue;
    yValue = _;
    return chart;
  };

  chart.unit = function(_) {
    if (!arguments.length) return unit;
    unit = _;
    return chart;
  };

  return chart;
}
