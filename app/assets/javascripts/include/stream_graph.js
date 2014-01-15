function streamGraph () {
  /* Variables for the view */
  var margin = {top: 10, right: 20, bottom: 20, left: 50},
    margin2 = {top: 40, right: 20, bottom: 20, left: 50},
    width = 800,
    height = 500,
    height2 = 150,
    xScale = d3.time.scale(),
    yScale = d3.scale.linear(),
    xScale2 = d3.time.scale(),
    yScale2 = d3.scale.linear(),
    xAxis = d3.svg.axis().scale(xScale).orient("bottom").tickSize(0, 0),
    yAxis = d3.svg.axis().scale(yScale).orient("left").tickSize(0).ticks(5),
    xAxis2 = d3.svg.axis().scale(xScale2).orient("bottom").tickSize(0, 0).ticks(5),
    yAxis2 = d3.svg.axis().scale(yScale2).orient("left").tickSize(0).ticks(2);

  /* Variables for the graph and data */
  var  parseDate = d3.time.format("%Y-%m-%dT%H:%M:%S.%L").parse,
    xValue = function(d) { return parseDate(d.timestamp); },
    yValue = function(d) { return d.value; },
    line = d3.svg.line().x(X).y(Y),
    line2 = d3.svg.line().x(X2).y(Y2),
    pline = d3.svg.line().x(X).y(Y),
    p_area_95 = d3.svg.area().x(X).y0(function(d){return yScale(d.lo95)}).y1(function(d){return yScale(d.hi95)}),
    p_area_80 = d3.svg.area().x(X).y0(function(d){return yScale(d.lo80)}).y1(function(d){return yScale(d.hi80)}),
    p_area_952 = d3.svg.area().x(X2).y0(function(d){return yScale2(d.lo95)}).y1(function(d){return yScale2(d.hi95)}),
    p_area_802 = d3.svg.area().x(X2).y0(function(d){return yScale2(d.lo80)}).y1(function(d){return yScale2(d.hi80)});
    
  function chart(selection) {
    selection.each(function(data) {
      chart.checkData = function() {
         // Calculate the scales
        data.data = data.data.map(function(d){
          if(typeof d.timestamp == "string")
            d.timestamp = parseDate(d.timestamp);
          return d;
        });
        //sort the data
        data.data = data.data.sort(function(a, b) {
            a = a.timestamp;
            b = b.timestamp;
            return a>b ? -1 : a<b ? 1 : 0;
        });
      }
      chart.checkData();
      chart.setAxises = function() {
      var x_domain;
      var y_domain;
      var data_x_domain = d3.extent(data.data, function(d){
        return d.timestamp;
      });
      var data_y_domain = d3.extent(data.data, function(d){
        return d.value;
      });
      if(data.pdata && data.pdata.length > 0){
        var pred_x_domain = d3.extent(data.pdata, function(d){
          return d.timestamp;
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
      var ypadding = (y_domain[1] - y_domain[0])*0.1;
      if(ypadding == 0){ ypadding = 0.5; }
      y_domain[0] -= ypadding;
      y_domain[1] += ypadding;
      }else{
      x_domain = data_x_domain;
      y_domain = data_y_domain;
      var ypadding = (y_domain[1] - y_domain[0])*0.1;
      if(ypadding == 0){ ypadding = 0.5; }
      y_domain[0] -= ypadding;
      y_domain[1] += ypadding;
      }
      xScale.domain(x_domain).range([0, width - margin.left - margin.right]);
      yScale.domain(y_domain).range([height - margin.top - margin.bottom, 0]);
      xScale2.domain(xScale.domain()).range(xScale.range());
      yScale2.domain(yScale.domain()).range([height2 - margin2.top - margin2.bottom, 0]);
      };

      chart.setAxises();
      // Create brush
      var brush = d3.svg.brush()
                    .x(xScale2)
                    .y(yScale2)
                    .on("brush", brushed);
      // Select the svg element, if it exists.
      var svg = d3.select(this).selectAll("svg").data([data]);
      
      console.log(data);
      // Otherwise, create the skeletal chart.
      var svgEnter = svg.enter().append("svg");

      svgEnter.append("clipPath").attr("id", "clip").append("svg:rect")
        .attr("id", "clip-rect")
        .attr("width", width -(margin.left+margin.right))
        .attr("height", height - (margin.top+margin.bottom));
          
      var focus = svgEnter.append("g").attr("transform", "translate(" + margin.left + "," + margin.top + ")");
          focus
            .append("rect")
            .attr("class", "svg-back")
            .attr("width", width-margin.left-margin.right)
            .attr("height", height-margin.top-margin.bottom);
          focus.append("g").attr("class", "x axis");
          focus.append("g").attr("class", "y axis");
          focus.append("g").attr("class", "lines");
          focus.append("g").attr("class", "datapoints");
          focus.select(".lines").append("path").attr("class", "area prediction-95");
          focus.select(".lines").append("path").attr("class", "area prediction-80");
          focus.select(".lines").append("path").attr("class", "prediction-line");
          focus.select(".lines")
               .append("path")
               .attr("class", "stream-line");

      var context = svgEnter.append("g").attr("transform", "translate(" + margin.left + "," + height + ")");
          context
            .append("rect")
            .attr("class", "svg-back")
            .attr("width", width-margin.left-margin.right)
            .attr("height", height2-margin2.top-margin2.bottom);
          context.append("path").attr("class", "area prediction-95");
          context.append("path").attr("class", "area prediction-80");
          context.append("g").attr("class", "lines");
          context.append("g").attr("class", "x axis");
          context.append("g")
                  .attr("class", "x brush")
                  .call(brush)
                  .selectAll("rect")
                  .attr("opacity", 0.1);

      // Update the outer dimensions.
      svg .attr("width", width)
          .attr("height", height + height2 + margin2.top);

      // Update the inner dimensions.

      focus.select(".lines").attr("clip-path", "url(#clip)");
      focus.select(".datapoints").attr("clip-path", "url(#clip)");
      var streams = focus.select(".stream-line").datum(data.data);
      //var lines = focus.select(".lines").selectAll(".stream-line").data([data.data]).attr("d", line);
      streams.attr("d", line);


      var streams2 = context.select(".lines").selectAll(".stream-line").data([data]);
      var lines2 = streams2.datum(function(d){return d.data;}).attr("d", line2);

      streams2
        .enter()
        .append("path")
        .attr("class", "stream-line")
        .datum(function(d){return d.data;})
        .attr("d", line2);


      //Update the predictions
      focus.select(".area.prediction-95")
              .datum(data.pdata)
              .attr("d", p_area_95);
      focus.select(".prediction-line")
              .datum(data.pdata)
              .attr("d", pline);
      // Update area for prediction with 80% confidence interval
      focus.select(".area.prediction-80")
              .datum(data.pdata)
              .attr("d", p_area_80);

      context.select(".area.prediction-95")
              .datum(data.pdata)
              .attr("d", p_area_95);
      // Update area for prediction with 80% confidence interval
      context.select(".area.prediction-80")
              .datum(data.pdata)
              .attr("d", p_area_80);
          
      // Update the x-axis.
      focus.select(".x.axis")
          .attr("transform", "translate(0," + yScale.range()[0] + ")")
          .call(xAxis);

      focus.select(".y.axis")
          .attr("transform", "translate(0," + xScale.range()[0] + ")")
          .call(yAxis);
      context.select(".x.axis")
          .attr("transform", "translate(0," + (yScale2.range()[0]) + ")")
          .call(xAxis2);

      chart.add_datapoints = function() {
        var datapoints = focus.select(".datapoints").selectAll("circle")
                        .data(data.data, function(d){return d.timestamp;});

      // Update existing data-points
      datapoints
          .transition() // start a transition to bring the new value into view
          .ease("linear")
          .duration(500)
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

      }
      chart.add_datapoints();


      chart.update = function(_){
        chart.checkData();
        var extent = brush.extent();
        xScale.domain(brush.empty() ? xScale2.domain() : [ extent[0][0], extent[1][0] ]);
        yScale.domain(brush.empty() ? yScale2.domain() : [ extent[0][1], extent[1][1] ]);
        var translation = xScale2(data.data[0].timestamp);
        var brushWidth = d3.select("rect.extent").attr("width");
        var transw = width;
        //console.log(translation);
        if(brushWidth != 0 ){
          var transw  = brushWidth/width;
          var tempscale = width/brushWidth;
          var tempi = (translation-width)+margin.left+margin.right;
          var testtrans = tempi*tempscale;
          translation = testtrans-(margin.left+margin.right);
          console.log(tempi);
        }
        chart.setAxises();
        xScale.domain(brush.empty() ? xScale2.domain() : [ extent[0][0], extent[1][0] ]);
        yScale.domain(brush.empty() ? yScale2.domain() : [ extent[0][1], extent[1][1] ]);
        focus.select(".x.axis").transition() // start a transition to bring the new value into view
          .ease("linear")
          .duration(500).call(xAxis);
        focus.select(".y.axis").transition() // start a transition to bring the new value into view
          .ease("linear")
          .duration(500).call(yAxis);
        context.select(".x.axis").transition() // start a transition to bring the new value into view
          .ease("linear")
          .duration(500).call(xAxis2);
        context.select(".y.axis").transition() // start a transition to bring the new value into view
          .ease("linear")
          .duration(500).call(yAxis2);
        
        streams
          .datum(data.data)
          .attr("d", line)
          .attr("transform", "translate(" + (translation-transw+margin.left+margin.right) + ")")
          .transition() // start a transition to bring the new value into view
          .ease("linear")
          .duration(500) // for this demo we want a continual slide so set this to the same as the setInterval amount below
          .attr("transform", "translate(" + xScale(data.data[0].timestamp)-width+margin.left+margin.right + ")");

        console.log("trans: " + (xScale(data.data[0].timestamp)-width+margin.left+margin.right));
        //console.log(xScale(data.data[1].timestamp)-width+margin.left+margin.right);
        //Update predictions
        focus.select(".area.prediction-95")
              .datum(data.pdata)
              .attr("d", p_area_95);
        // Update area for prediction with 80% confidence interval
        focus.select(".area.prediction-80")
              .datum(data.pdata)
              .attr("d", p_area_80);
        focus.select(".prediction-line")
              .datum(data.pdata)
              .attr("d", pline);
        context.select(".area.prediction-95")
              .datum(data.pdata)
              .attr("d", p_area_952);
        // Update area for prediction with 80% confidence interval
        context.select(".area.prediction-80")
              .datum(data.pdata)
              .attr("d", p_area_802);
        context.select(".stream-line").datum(data.data).attr("d", line2);
        chart.add_datapoints();

      };

      function brushed() {
        var extent = brush.extent();
        xScale.domain(brush.empty() ? xScale2.domain() : [ extent[0][0], extent[1][0] ]);
        yScale.domain(brush.empty() ? yScale2.domain() : [ extent[0][1], extent[1][1] ]);
        focus.select(".x.axis").call(xAxis);
        focus.select(".y.axis").call(yAxis);
        streams.attr("d", line);
        focus.select(".area.prediction-80").datum(data.pdata).attr("d", p_area_80);
        focus.select(".area.prediction-95").datum(data.pdata).attr("d", p_area_95);
        focus.select(".prediction-line").datum(data.pdata).attr("d", pline);
        focus.select(".datapoints").selectAll("circle")
          .attr("cx", function(d) {return X(d)})
          .attr("cy", function(d) {return Y(d)});
      }
    });
  }

  // The x-accessor for the path generator; xScale xValue.
  function X(d) {
    return xScale(d.timestamp);
  }

  // The x-accessor for the path generator; yScale yValue.
  function Y(d) {
    return  yScale(d.value);
  }
  // The x-accessor for the path generator; xScale xValue.
  function X2(d) {
    return xScale2(d.timestamp);
  }

  // The x-accessor for the path generator; yScale yValue.
  function Y2(d) {
    return  yScale2(d.value);
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
