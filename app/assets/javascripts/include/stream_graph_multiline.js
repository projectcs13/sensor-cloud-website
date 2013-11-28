function streamGraphMultiLine () {
  /* Variables for the view */
  var margin = {top: 40, right: 20, bottom: 20, left: 50},
    margin2 = {top: 40, right: 20, bottom: 20, left: 50},
    width = 760,
    height = 500,
    height2 = 100,
    xScale = d3.time.scale(),
    yScale = d3.scale.linear(),
    xScale2 = d3.time.scale(),
    yScale2 = d3.scale.linear(),
    xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(0, 0),
    yAxis = d3.svg.axis().scale(yScale).orient("left").tickSize(0).ticks(5),
    xAxis2 = d3.svg.axis().scale(xScale2).orient("bottom").tickSize(0, 0).ticks(4);

  /* Variables for the graph and data */
  var  parseDate = d3.time.format("%Y-%m-%dT%H:%M:%S.%L").parse,
    xValue = function(d) { return parseDate(d.timestamp); },
    yValue = function(d) { return d.value; },
    colors = ["#00ff00", "#000000", "#ff0000", "#0000ff", "#342432", "#237282"],
    line = d3.svg.line().x(X).y(Y).interpolate("monotone"),
    line2 = d3.svg.line().x(function(d) {return xScale2(parseDate(d.timestamp)); }).y(function(d) { return yScale2(d.value); }),
    real_data = function(d) { return d.data; },
    datasets = [];
    
  function chart(selection) {
    selection.each(function(data) {

      /* Setting up the domain and range for the axis */
      var x_domain = d3.extent(data[0].data, function(d) { return parseDate(d.timestamp); });
      var y_domain = d3.extent(data[0].data, function(d) { return d.value; })
      for(var i = 0; i < data.length; i++){
        var d = data[i];
        if(d.data.length > 1){
          var tempx_extent = d3.extent(d.data, function(d) { return parseDate(d.timestamp); });
          var tempy_extent = d3.extent(d.data, function(d) { return d.value; });
          y_domain[0] = Math.min(tempy_extent[0], y_domain[0]);
          y_domain[1] = Math.max(tempy_extent[1], y_domain[1]);
          x_domain[0] = Math.min(tempx_extent[0], x_domain[0]);
          x_domain[1] = Math.max(tempx_extent[1], x_domain[1]);
        }
      };
      xScale.domain(x_domain).range([0, width - margin.left - margin.right]);
      yScale.domain(y_domain).range([height - margin.top - margin.bottom, 0]);
      xScale2.domain(xScale.domain()).range(xScale.range());
      yScale2.domain(yScale.domain()).range([height2 - margin.top - margin.bottom, 0]);
      console.log("x_domain:" + x_domain);
      console.log("y_domain:" + y_domain);
      // Create brush
      var brush = d3.svg.brush()
                    .x(xScale2)
                    .on("brush", brushed);
      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([data]);
      // Otherwise, create the skeletal chart.
      var svgEnter = svg.enter().append("svg")
      var focus = svgEnter.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
      var context = svgEnter.append("g").attr("transform", "translate(" + margin.left + "," + height + ")");
          focus.append("g").attr("class", "x axis");
          focus.append("g").attr("class", "y axis");
          focus.append("g").attr("class", "lines");
          context.append("g").attr("class", "lines");
          context.append("g").attr("transform", "translate(0, 100)").attr("class", "x axis");
          context.append("g")
                  .attr("class", "x brush")
                  .call(brush)
                  .selectAll("rect")
                  .attr("opacity", 0.1)
                  .attr("y", -6)
                  .attr("height", height2);

      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height + height2);


      // Update the inner dimensions.
      var streams = focus.select(".lines").selectAll(".stream-line").data(data, function(d){return d.stream_id;});
      var lines = streams.datum(function(d){return d.data;}).attr("d", line);
      
      streams
                  .enter()
                  .append("path")
                  .attr("class", "stream-line")
                  .attr("id", function(d){return d.stream_id})
                  .attr("stroke", function(d, i){ return colors[i]; })
                  .datum(function(d){return d.data;})
                  .attr("d", line);

      var streams2 = context.select(".lines").selectAll(".stream-line").data(data, function(d){return d.stream_id;});
      var lines2 = streams2.datum(function(d){return d.data;}).attr("d", line2);
      
      streams2
                  .enter()
                  .append("path")
                  .attr("class", "stream-line")
                  .attr("id", function(d){return d.stream_id})
                  .attr("stroke", function(d, i){ return colors[i]; })
                  .datum(function(d){return d.data;})
                  .attr("d", line2);
          
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
        xScale.domain(brush.empty() ? xScale2.domain() : brush.extent());
        focus.select(".x.axis").call(xAxis);
        focus.select(".y.axis").call(yAxis);
        lines.attr("d", line);
      }
    });
  }

  // The x-accessor for the path generator; xScale xValue.
  function X(d) {
    return xScale(parseDate(d.timestamp));
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
