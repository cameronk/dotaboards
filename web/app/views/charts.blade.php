<html>
<head>
	<title>Charts | Dotaboards</title>
	<script type="text/javascript" src="//cdn.azuru.me/db/js/charts.min.js"></script>
</head>
<body>


<canvas id="delay" width="1820" height="950"></canvas>



<script>
	var ctx = document.getElementById("delay").getContext("2d");
	var monitorData = {{ $regions }};

	var labels = [];
	var actualData = [];
	monitorData["delays"].map(function(delay, index) {
		labels.push("-" + (( monitorData["delays"].length - index ) * 20));
		actualData.push(delay);
	});

	var data = { 
		labels: labels,
		datasets: [
			{
	            label: "Delays",
	            fillColor: "rgba(220,220,220,0.2)",
	            strokeColor: "rgba(220,220,220,1)",
	            pointColor: "rgba(220,220,220,1)",
	            pointStrokeColor: "#fff",
	            pointHighlightFill: "#fff",
	            pointHighlightStroke: "rgba(220,220,220,1)",
	            data: actualData
	        },
		]
	};

	var myNewChart = new Chart(ctx).Line(data);
</script>
</body>
</html>