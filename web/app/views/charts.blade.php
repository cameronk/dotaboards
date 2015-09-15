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
		background: #ddd;
		border: 1px solid #777;
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
		margin-left: 5px;
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

	<h1>Total requests vs. response time</h1>
	<div id="graph-rr" class="graph"></div>

	<h1>Downtime</h1>
	<div id="graph-downtime" class="graph"></div>
</div>

<script>

	var data = {{ $regions }};

	var delays = [];
	var mpr = [];
	var rr = [];
	var downtime = [];

	data.map(function(pushLoop, index) {
		// labels_time.push(pushLoop['recordedAt']);
		// labels_index.push("-" + (data.length - index));


		// // Delays //
		// calc_delays_average += pushLoop['delay'];
		// compile_delays.push(Math.round(pushLoop['delay']));

		// // MPR //
		// compile_mpr.push(pushLoop["averageMatchesPerRequest"]);

		// // Request/response //
		// compile_requests.push(pushLoop["requests"]);
		// compile_responseTime.push(pushLoop["averageFetchResponseTime"]);




		/**
		 * Delays
		 */
		delays.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['delay']) ]);


		/**
		 * MPR
		 */
		mpr.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['averageMatchesPerRequest']) ]);

	
		/**
		 * Request/response
		 */
		rr.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['requests']), Math.round(pushLoop['averageFetchResponseTime']) ]);


		/**
		 * Downtime
		 */
		downtime.push([ new Date(pushLoop['recordedAt']), Math.abs(pushLoop['downtime']) ]);

	});



	// delay
	new Dygraph(document.getElementById("graph-delay"),
      delays,
      {
        labels: [ "Date", "Delay" ],
        showInRangeSelector: true,
        fillGraph: true,
      });

	// mpr
	new Dygraph(document.getElementById("graph-mpr"),
      mpr,
      {
        labels: [ "Date", "Matches per request" ],
        showInRangeSelector: true,
        fillGraph: true,
      });

	// rr
	new Dygraph(document.getElementById("graph-rr"),
      rr,
      {
        labels: [ "Date", "Requests", "Avg. fetch response time" ],
        showInRangeSelector: true,
        fillGraph: true,
      });

    // rr
	new Dygraph(document.getElementById("graph-downtime"),
      downtime,
      {
        labels: [ "Date", "Downtime" ],
        showInRangeSelector: true,
        fillGraph: true,
      });



</script>
</body>
</html>