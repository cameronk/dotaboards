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

	// tr
	new Dygraph(document.getElementById("graph-tr"),
      rr,
      {
        labels: [ "Date", "Requests" ],
        showInRangeSelector: true,
        fillGraph: true,
      });

    // downtime
	new Dygraph(document.getElementById("graph-downtime"),
      downtime,
      {
        labels: [ "Date", "Downtime" ],
        showInRangeSelector: true,
        fillGraph: true,
      });

 	// ppr
	new Dygraph(document.getElementById("graph-ppr"),
      ppr,
      {
        labels: ["Date", "Global", "US", "EU", "Asia", "Africa", "Russia", "South America", "Australia"],
        showInRangeSelector: true,
        fillGraph: true,
      });



</script>
</body>
</html>