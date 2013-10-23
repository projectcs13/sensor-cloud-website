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
      xValue = function(d) { return d.date; },
      yValue = function(d) { return d.value; },
      xScale = d3.time.scale(),
      yScale = d3.scale.linear(),
      xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(6, 0),
      yAxis = d3.svg.axis().scale(yScale).orient("left"),
      area = d3.svg.area().x(X).y(Y),
      line = d3.svg.line().x(X).y(Y);

  function chart(selection) {
    selection.each(function(data) {
      // Convert data to standard representation greedily;
      // this is needed for nondeterministic accessors.
      data = data.map(function(d, i) {
        return [xValue.call(data, d, i), yValue.call(data, d, i)];
      });

      // Update the x-scale.
      xScale
          .domain(d3.extent(data, function(d) { return d[0]; }))
          .range([0, width - margin.left - margin.right]);

      // Update the y-scale.
      yScale
          .domain([0, d3.max(data, function(d) { return d[1]; })])
          .range([height - margin.top - margin.bottom, 0]);

      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([data]);
      

      // Otherwise, create the skeletal chart.
      var gEnter = svg.enter().append("svg").append("g");
        gEnter.append("path").attr("class", "area");
        gEnter.append("path").attr("class", "line").attr("d", line);
        gEnter.append("g").attr("class", "x axis");
        gEnter.append("g").attr("class", "y axis");
        gEnter.append("g").attr("class", "datapoints");
      
      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height);

      // Update the inner dimensions.
      var g = svg.select("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      // Update the area path.
      g.select(".area")
          .data([data]) // set the new data
          .attr("transform", "translate(" + 40 + ")")
          .attr("d", area.y0(yScale.range()[0]))
          .transition()
          .duration(200)
          .attr("transform", "translate(" + "0" + ")");

      var twoYear = parseDate("2028-12-12");
      var zeroYear = parseDate("2026-12-12");
      // Update the line path.
      g.select(".line")
          .data([data]) // set the new data
          .attr("transform", "translate(" + 40 + ")") // set the transform to the right by x(1) pixels (6 for the scale we've set) to hide the new value
          .attr("d", line) // apply the new data values ... but the new value is hidden at this point off the right of the canvas
          .transition() // start a transition to bring the new value into view
          .duration(200) // for this demo we want a continual slide so set this to the same as the setInterval amount below
          .attr("transform", "translate(" + "0" + ")");

      // Update the x-axis.
      g.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis);

      g.select(".y.axis")
          .attr("transform", "translate(0," + xScale.range()[0] + ")")
          .call(yAxis);

      // Select all datapoints if they exist
      var datapoints = g.select(".datapoints").selectAll("circle")
                        .data(data, function(d){return d[0]});

      // Add datapoints that don't exist
      datapoints
          .enter()
          .append("circle")
          .attr("cx", function(d) {return xScale(d[0])})
          .attr("cy", function(d) {return yScale(d[1])})
          .attr("r", 4)
          .attr("class", "datapoint")
          .append("title")
          .text( function(d) {return d[1]});
      
      // Update the datapoints
      datapoints
          .transition()
          .duration(200)
          //.ease("linear")
          .attr("cx", function(d) {return xScale(d[0])})
          .attr("cy", function(d) {return yScale(d[1])});

      datapoints
        .exit()
        .remove()

    });
  }

  // The x-accessor for the path generator; xScale xValue.
  function X(d) {
    return xScale(d[0]);
  }

  // The x-accessor for the path generator; yScale yValue.
  function Y(d) {
    return yScale(d[1]);
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

  return chart;
}
