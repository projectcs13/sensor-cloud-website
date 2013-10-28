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
      predicted_data = function(d) { return d.pdata },
      real_data = function(d) { return d.data },
      xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(6, 0),
      yAxis = d3.svg.axis().scale(yScale).orient("left").tickSize(10).ticks(5),
      line = d3.svg.line().x(X).y(Y).interpolate("monotone"),
      p_area_95 = d3.svg.area().x(X).y0(function(d){return yScale(d.lo95)}).y1(function(d){return yScale(d.hi95)}).interpolate("monotone"),
      p_area_80 = d3.svg.area().x(X).y0(function(d){return yScale(d.lo80)}).y1(function(d){return yScale(d.hi80)}).interpolate("monotone");


  function chart(selection) {
    selection.each(function(data) {
      // Convert data to standard representation greedily;
      // this is needed for nondeterministic accessors.

      // Calculate the scales
      var x_domain;
      var y_domain;
      var data_x_domain = d3.extent(data.data, function(d){
        return d.date;
      });
      var data_y_domain = d3.extent(data.data, function(d){
        return d.value;
      });
      if(data.pdata && data.pdata.length > 0){
        var pred_x_domain = d3.extent(data.pdata, function(d){
          return d.date;
        });
        var pred_y_min = d3.min(data.pdata, function(d){
          return Math.min(d.value, d.lo80, d.lo95);
        });
        var pred_y_max = d3.max(data.pdata, function(d){
          return Math.max(d.value, d.hi80, d.hi95);
        });
      x_domain = [Math.min(data_x_domain[0], pred_x_domain[0]), 
                  Math.max(data_x_domain[1], pred_x_domain[1])];
      y_domain = [Math.min(data_y_domain[0], pred_y_min), Math.max(data_y_domain[1], pred_y_max)];

      }else{
      x_domain = data_x_domain;
      y_domain = data_y_domain;
      }

      // Update the X-Scale
      xScale
          .domain(x_domain)
          .range([0, width - margin.left - margin.right]);
      // Update the Y-Scale
      yScale
          .domain(y_domain)
          .range([height - margin.top - margin.bottom, 0]);

      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([data]);
      

      // Otherwise, create the skeletal chart.
      var gEnter = svg.enter().append("svg").append("g");
        gEnter.append("path").attr("class", "line");
        gEnter.append("path").attr("class", "area p-area-95");
        gEnter.append("path").attr("class", "area p-area-80");
        gEnter.append("path").attr("class", "p-line");
        gEnter.append("path").attr("class", "p-area80");
        gEnter.append("line").attr("class", "delimiter");
        gEnter.append("g").attr("class", "x axis");
        gEnter.append("g").attr("class", "y axis");
        gEnter.append("g").attr("class", "p-datapoints");
        gEnter.append("g").attr("class", "datapoints");
      
      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height);

      // Update the inner dimensions.
      var g = svg.select("g")
          .attr("transform", "translate(" + margin.left + "," + margin.top + ")");

      // Update area for prediction with 95% confidence interval
      g.select(".p-area-95")
              .datum(predicted_data)
              .attr("d", p_area_95);
      // Update area for prediction with 80% confidence interval
      g.select(".p-area-80")
              .datum(predicted_data)
              .attr("d", p_area_80);
      // Update the line path.
       g.select(".line")
          .datum(real_data)
          .attr("d", line);

        g.select(".p-line")
         .datum(predicted_data)
         .attr("d", line);

      // Update the x-axis.
      g.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis);

      g.select(".y.axis")
          .attr("transform", "translate(0," + xScale.range()[0] + ")")
          .call(yAxis);

      // Select all data-points if they exist
      var datapoints = g.select(".datapoints").selectAll("circle")
                        .data(real_data);

      // Update existing data-points
      datapoints
          .attr("cx", function(d) {return X(d)})
          .attr("cy", function(d) {return Y(d)});

      // Add datapoints that don't exist
      datapoints
          .enter()
          .append("circle")
          .attr("cx", function(d) {return X(d)})
          .attr("cy", function(d) {return Y(d)})
          .attr("r", 3)
          .on("mouseover", function(){
            d3.select(this).transition().attr("r", 6);
          })
          .on("mouseout", function(){
            d3.select(this).transition().attr("r", 3);
          })
          //.attr("class", "datapoint")
          .append("title")
          .text( function(d) {return d.value})

      // Remove datapoints that don't exist
      datapoints
        .exit()
        .remove();


      // Select all predicted data-points if they exist
      var pdatapoints = g.select(".p-datapoints").selectAll("circle")
                         .data(predicted_data);

      // Update the predicted data-points
      pdatapoints
           .attr("cx", function(d) {return X(d)})
           .attr("cy", function(d) {return Y(d)});
      // // Add pdatapoints that don't exist
      pdatapoints
          .enter()
          .append("circle")
          .attr("cx", function(d) {return X(d)})
          .attr("cy", function(d) {return Y(d)})
          .attr("r", 3)
          .on("mouseover", function(){
            d3.select(this).transition().attr("r", 6);
          })
          .on("mouseout", function(){
            d3.select(this).transition().attr("r", 3);
          })
          //.attr("class", "datapoint")
          .append("title")
          .text( function(d) {return d.value});
      
      // Remove predicted data-points that don't exist anymore
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
