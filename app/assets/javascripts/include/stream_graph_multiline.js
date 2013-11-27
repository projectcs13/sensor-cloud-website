function streamGraphMultiLine () {
  /* Variables for the view */
  var margin = {top: 40, right: 20, bottom: 20, left: 50},
    margin2 = {top: 40, right: 20, bottom: 20, left: 50},
    width = 760,
    height = 500,
    height2 = 200,
    xScale = d3.time.scale(),
    yScale = d3.scale.linear(),
    xScale2 = d3.time.scale(),
    yScale2 = d3.scale.linear(),
    xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(0, 0),
    yAxis = d3.svg.axis().scale(yScale).orient("left").tickSize(0).ticks(5),
    xAxis2 = d3.svg.axis().scale(xScale2).orient("bottom").tickSize(0, 0);

  /* Variables for the graph and data */
  var  parseDate = d3.time.format("%Y-%m-%dT%H:%M:%S.%L").parse,
    xValue = function(d) { return d.timestamp; },
    yValue = function(d) { return d.value; },
    colors = ["#00ff00", "#000000", "#ff0000", "#0000ff", "#342432", "#237282"],
    line = d3.svg.line().x(X).y(Y).interpolate("monotone"),
    real_data = function(d) { return d.data; },
    datasets = [];
    
  function chart(selection) {
    selection.each(function(data) {

      /* Setting up the domain and range for the axis */
      var x_domain = d3.extent(data[3].data, function(d) { return d.timestamp; });
      var y_domain = d3.extent(data[3].data, function(d) { return d.value; })
      console.log(data);
      data.forEach(function(d){
        if(d.length > 0){
          tempx_extent = d3.extent(d.data, function(d) { return d.timestamp; });
          tempy_extent = d3.extent(d.data, function(d) { return d.value; });
          x_domain[0] = d3.min(x_domain[0], tempx_extent[0]);
          x_domain[1] = d3.max(x_domain[1], tempx_extent[1]);
          y_domain[0] = d3.min(y_domain[0], tempy_extent[0]);
          y_domain[1] = d3.max(y_domain[1], tempy_extent[1]);
        }
      });
      xScale.domain(x_domain).range([0, width - margin.left - margin.right]);
      yScale.domain(y_domain).range([height - margin.top - margin.bottom, 0]);
      xScale2.domain(xScale.domain()).range(xScale.range());
      yScale2.domain(yScale.domain()).range(yScale.range());

      // Create brush
      var brush = d3.svg.brush()
                    .x(xScale2)
                    .on("brush", brushed);
      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([data]);
      // Otherwise, create the skeletal chart.
      var svgEnter = svg.enter().append("svg")
      var focus = svgEnter.append("g");
      var context = svgEnter.append("g");
          focus.append("g").attr("class", "x axis");
          focus.append("g").attr("class", "y axis");
          focus.attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          context.append("g").attr("class", "x axis");
          context.attr("transform", "translate(" + margin2.left + "," + margin2.top + ")");
          context.append("g").attr("class", "x brush")
                  .call(brush)
                  .selectAll("rect")
                  .attr("opacity", 0.1)
                  .attr("y", -6)
                  .attr("height", height2 + 7);

      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height + height2);


      // Update the inner dimensions.

      var streams = focus.selectAll(".stream-line").data(data);

      streams.attr("id", function(d){return d.stream_id});
      streams.datum(real_data).attr("d", line);
      
      var lines = streams
                  .enter()
                  .append("path")
                  .attr("class", "stream-line")
                  .attr("id", function(d){return d.stream_id})
                  .attr("stroke", function(d, i){ return colors[i]; })
                  .datum(function(d){return d.data})
                  .attr("d", line);

          
      // Update the x-axis.
      focus.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis);

      focus.select(".y.axis")
          .attr("transform", "translate(0," + xScale.range()[0] + ")")
          .call(yAxis);
      context.select(".x.axis")
          .attr("transform", "translate(0," + (yScale2.range()[0] - margin2.top) + ")")
          .call(xAxis2);

      function brushed() {
        console.log("helloo...");
        xScale.domain(brush.empty() ? xScale2.domain() : brush.extent());
        streams.attr("d", line);
        focus.select(".x.axis").call(xAxis);
        focus.select(".y.axis").call(yAxis);
      }


    });
  }

  // The x-accessor for the path generator; xScale xValue.
  function X(d) {
    return xScale(d.timestamp);
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

  chart.add_dataset = function(dataset) {
    datasets.push(dataset);
    return chart;
  }
  chart.remove_dataset = function(dataset) {
    datasets.pop();
    return chart;
  }

  return chart;
}
