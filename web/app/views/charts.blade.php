<html>
<head>
	<title>Charts | Dotaboards</title>
	<script src="//cdnjs.cloudflare.com/ajax/libs/dygraph/1.1.1/dygraph-combined.js"></script>
	<link href='https://fonts.googleapis.com/css?family=Lato:400,700,300' rel='stylesheet' type='text/css'>
	<style>
	body {
		position: relative;
		padding: 0;
		margin: 0;
		font-family: "Lato", sans-serif;
	}



	.contain {
		width: 960px;
		margin: 0 auto;
	}



	#header {
		height: 80px;
		background: #222;
		font-size: 30px;
		line-height: 80px;
		color: #dedede;
	}

	#content {
		background: #e4e4e4;
		border: 1px solid #999;
		border-top: none;
		margin-bottom: 50px;
		padding-bottom: 10px;
	}

		#content h1 {
			border-bottom: 1px solid #777;
			margin: 0;
			padding: 10px;
		}


	.graph {
		width: 100% !important;
		background: #f5f5f5;
	}

	small {
		font-weight: lighter;
		font-size: 20px;
	}
	</style>
</head>
<body>


<div id="header">
	<div class="contain">
	Dotaboards &mdash; statistical charts
	</div>
</div>
<div id="content" class="contain">

	<h1>Delays <small>(diff. between completion and recording times)</small></h1>
	<div id="graph-delay" class="graph"></div>	

	<h1>Matches returned per request</h1>
	<div id="graph-mpr" class="graph"></div>	

	<h1>Fetch requests vs. response time</h1>
	<div id="graph-rr" class="graph"></div>
	
	<h1>Total requests</h1>
	<div id="graph-tr" class="graph"></div>

	<h1>Downtime</h1>
	<div id="graph-downtime" class="graph"></div>

	<h1>Players Processed <small>by region</small></h1>
	<div id="graph-ppr" class="graph"></div>
</div>

<script>

	var data = {{ $regions }};

	var delays = [];

	var delaysAverage = 0;
	var mpr = [];
	var rr = [];
	var tr = [];
	var downtime = [];
	var ppr = [];

	data.map(function(pushLoop, index) {

		/**
		 * Delays
		 */
		delays.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['delay']) ]);
		delaysAverage += pushLoop['delay'];


		/**
		 * MPR
		 */
		mpr.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['averageMatchesPerRequest']) ]);

	
		/**
		 * Request/response
		 */
		rr.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['fetchRequestResponses']), Math.round(pushLoop['averageFetchResponseTime']) ]);


		/**
		 * Total requests
		 */
		tr.push([ new Date(pushLoop['recordedAt']), pushLoop['totalRequests'] ]);


		/**
		 * Downtime
		 */
		downtime.push([ new Date(pushLoop['recordedAt']), Math.abs(pushLoop['downtime']) ]);

		/**
		 * PPR (playersProcessed)
		 */
		var procs = pushLoop['processors'];
		var thisPushPlayerProcessed = [ new Date(pushLoop['recordedAt']) ];
		for(var region in procs) {
			thisPushPlayerProcessed.push(procs[region]["playersProcessed"]);
		}
		ppr.push(thisPushPlayerProcessed);

	});

	var compiledAverage = Math.round(delaysAverage / data.length);
	delays.map(function(delay, index) {
		delays[index].push(compiledAverage);
	});

	// delay
	new Dygraph(document.getElementById("graph-delay"),
      delays,
      {
	    ylabel: "Delay (minutes)",
        labels: [ "Date", "Delay", "Average" ],
        showInRangeSelector: true,
        fillGraph: true,
      }
    );

	// mpr
	new Dygraph(document.getElementById("graph-mpr"),
      mpr,
      {
	    ylabel: "# of matches",
        labels: [ "Date", "Matches per request" ],
        showInRangeSelector: true,
        fillGraph: true,
      }
    );

	// rr
	new Dygraph(document.getElementById("graph-rr"),
      rr,
      {
	    ylabel: "Requests (#) / avg response time (ms)",
        labels: [ "Date", "Requests", "Avg. fetch response time" ],
        showInRangeSelector: true,
        fillGraph: true,
      }
    );

	// tr
	new Dygraph(document.getElementById("graph-tr"),
      tr,
      {
	    ylabel: "# of requests",
      	axes: {
      		y: {
      			axisLabelFormatter: function(x) {
      				return Math.round(x / 1000) + "k";
      			}
      		}
      	},
        labels: [ "Date", "Requests" ],
        showInRangeSelector: true,
        fillGraph: true,
      }
    );

    // downtime
	new Dygraph(document.getElementById("graph-downtime"),
      downtime,
      {
	    ylabel: "Downtime (min)",
        labels: [ "Date", "Downtime" ],
        showInRangeSelector: true,
        fillGraph: true,
      }
    );

 	// ppr
	var pprGraph = new Dygraph(document.getElementById("graph-ppr"),
		ppr,
		{
	      	ylabel: "# of players",
	      	rollPeriod: 3,
	      	showRoller: true,

	      	axes: {
	      		y: {
	      			axisLabelFormatter: function(x) {
	      				return Math.round(x / 1000) + "k";
	      			}
	      		}
	      	},

	      	series: {
	      		Global: {
	      			strokeWidth: 4
	      		}
	      	},

	      	highlightSeriesOpts: {
	          strokeWidth: 3,
	          strokeBorderWidth: 1,
	          highlightCircleSize: 5
	        },

	        labels: ["Date", "Global", "US", "EU", "Asia", "Africa", "Russia", "South America", "Australia"],
	        showInRangeSelector: true,
	        stackedGraph: true,

	        underlayCallback: function(canvas, area, g) {

	            canvas.fillStyle = "rgba(0,0,0,0.4)";

	            function highlight_period(x_start, x_end) {
	              var canvas_left_x = g.toDomXCoord(x_start);
	              var canvas_right_x = g.toDomXCoord(x_end);
	              var canvas_width = canvas_right_x - canvas_left_x;
	              canvas.fillRect(canvas_left_x, area.y, canvas_width, area.h);
	            }

	            var min_data_x = g.getValue(0,0);
	            var max_data_x = g.getValue(g.numRows()-1,0);

	            // get day of week
	            var d = new Date(min_data_x);
	            var dow = d.getUTCDay();

	            var w = min_data_x;
	            // starting on Sunday is a special case
	            if (dow === 0) {
	              highlight_period(w,w+12*3600*1000);
	            }
	            // find first saturday
	            while (dow != 6) {
	              w += 24*3600*1000;
	              d = new Date(w);
	              dow = d.getUTCDay();
	            }
	            // shift back 1/2 day to center highlight around the point for the day
	            w -= 12*3600*1000;
	            while (w < max_data_x) {
	              var start_x_highlight = w;
	              var end_x_highlight = w + 2*24*3600*1000;
	              // make sure we don't try to plot outside the graph
	              if (start_x_highlight < min_data_x) {
	                start_x_highlight = min_data_x;
	              }
	              if (end_x_highlight > max_data_x) {
	                end_x_highlight = max_data_x;
	              }
	              highlight_period(start_x_highlight,end_x_highlight);
	              // calculate start of highlight for next Saturday 
	              w += 7*24*3600*1000;
	            }
	        }
      	}
    );

	var pprOnclick = function(ev) {
		if (pprGraph.isSeriesLocked()) {
			pprGraph.clearSelection();
		} else {
			pprGraph.setSelection(pprGraph.getSelection(), pprGraph.getHighlightSeries(), true);
		}
	};
	pprGraph.updateOptions({clickCallback: pprOnclick}, true);


</script>
</body>
</html>