<html>
<head>
	<title>Charts | Dotaboards</title>
	<script src="https://code.jquery.com/jquery-2.1.4.min.js"></script>
	<script src="//cdn.azuru.me/db/js/highcharts.js"></script>
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
		background: #f4f4f4;
		border: 1px solid #aaa;
		border-top: none;
		margin-bottom: 50px;
		padding-bottom: 10px;
	}

		#content h1 {
			border-bottom: 1px solid #aaa;
			border-top: 1px solid #aaa;
			margin: 0;
			padding: 10px;
		}


	.graph {
		width: 100% !important;
	}
	#graph-ppr {
		height: 750px !important;
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

	<!-- <h1>Downtime</h1>
	<div id="graph-downtime" class="graph"></div> -->

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



	var playersProcessed = { };
	var requestResponse = [{ name: 'Fetch request responses', data: [] }, { name: 'Average fetch response time', yAxis: 1, data: []}];
	data.map(function(pushLoop, index) {

		/**
		 * Delays
		 */
		delays.push([ Date.parse(pushLoop['recordedAt']), Math.round(pushLoop['delay']) ]);

		/**
		 * MPR
		 */
		mpr.push([ Date.parse(pushLoop['recordedAt']), Math.round(pushLoop['averageMatchesPerRequest']) ]);

	
		/**
		 * Request/response
		 */
		// rr.push([ new Date(pushLoop['recordedAt']), Math.round(pushLoop['fetchRequestResponses']), Math.round(pushLoop['averageFetchResponseTime']) ]);
		requestResponse[0].data.push([ Date.parse(pushLoop['recordedAt']), Math.round(pushLoop['fetchRequestResponses']) ]);
		requestResponse[1].data.push([ Date.parse(pushLoop['recordedAt']), Math.round(pushLoop['averageFetchResponseTime']) ]);


		/**
		 * Total requests
		 */
		tr.push([ Date.parse(pushLoop['recordedAt']), pushLoop['totalRequests'] ]);


		/**
		 * Downtime
		 */
		downtime.push([ new Date(pushLoop['recordedAt']), Math.abs(pushLoop['downtime']) ]);

		/**
		 * PPR (playersProcessed)
		 */
		// var procs = pushLoop['processors'];
		// var thisPushPlayerProcessed = [ Date.parse(pushLoop['recordedAt']) ];
		// for(var region in procs) {
		// 	thisPushPlayerProcessed.push(procs[region]["playersProcessed"]);
		// }
		// ppr.push(thisPushPlayerProcessed);

		for(var region in pushLoop['processors']) {
			if(!playersProcessed.hasOwnProperty(region)) {
				playersProcessed[region] = { 'name': region, 'data': []};
			}

			playersProcessed[region]['data'].push([ Date.parse(pushLoop['recordedAt']), pushLoop['processors'][region]['playersProcessed'] ]);
		}

	});



	$(document).ready(function() {

		/**
	     * In order to synchronize tooltips and crosshairs, override the 
	     * built-in events with handlers defined on the parent element.
	     */
	    $('#content').bind('mousemove touchmove', function (e) {
	        var chart,
	            point,
	            i;

	        for (i = 0; i < Highcharts.charts.length; i++) {
	            chart = Highcharts.charts[i];
	            e = chart.pointer.normalize(e); // Find coordinates within the chart
	            point = chart.series[0].searchPoint(e, true); // Get the hovered point

	            if (point) {
	                point.onMouseOver(); // Show the hover marker
	                chart.tooltip.refresh(point); // Show the tooltip
	                chart.xAxis[0].drawCrosshair(e, point); // Show the crosshair
	            }
	        }
	    });
	    /**
	     * Override the reset function, we don't need to hide the tooltips and crosshairs.
	     */
	    Highcharts.Pointer.prototype.reset = function () {};

	    /**
	     * Synchronize zooming through the setExtremes event handler.
	     */
	    function syncExtremes(e) {
	        var thisChart = this.chart;

	        Highcharts.each(Highcharts.charts, function (chart) {
	            if (chart !== thisChart) {
	                if (chart.xAxis[0].setExtremes) { // It is null while updating
	                    chart.xAxis[0].setExtremes(e.min, e.max);
	                }
	            }
	        });
	    }

	    /**
	     * Delay
	     */
		$("#graph-delay").highcharts({
			chart: {
				zoomType: 'x',
				type: 'area'
			},

			// titles
			title: {
				text: "Delay over time"
			},
			subtitle: {
				text: "difference between match completion and recording times"
			},

			// axes
			xAxis: {
				type: 'datetime',
				crosshair: true,
				title: {
					text: 'Date'
				},
                events: {
                    setExtremes: syncExtremes
                },

			},
			yAxis: {
				title: {
					text: 'Difference (min)'
				},
				plotBands: [{
					from: 0,
					to: 20,
					color: Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0.2).get('rgba')
				}]
			},

			legend: {
				enabled: false
			},
            plotOptions: {
                area: {
                    fillColor: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                        ]
                    },
                    marker: {
                        radius: 2
                    },
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 1
                        }
                    },
                    threshold: null
                }
            },

            series: [
            	{
            		name: 'Delay',
            		data: delays
            	}
            ]
		});
	
		
		/** 
		 * Matches per request
		 */
		$("#graph-mpr").highcharts({
			chart: {
				zoomType: 'x',
				type: 'area'
			},

			// titles
			title: {
				text: "Matches per request"
			},

			// axes
			xAxis: {
				type: 'datetime',
				crosshair: true,
				title: {
					text: 'Date'
				},
                events: {
                    setExtremes: syncExtremes
                },

			},
			yAxis: {
				title: {
					text: 'Matches (#)'
				}
			},

			legend: {
				enabled: false
			},
            plotOptions: {
                area: {
                    fillColor: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                        ]
                    },
                    marker: {
                        radius: 2
                    },
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 1
                        }
                    },
                    threshold: null
                }
            },

            series: [
            	{
            		name: 'Matches per request',
            		data: mpr
            	}
            ]
		});
		
		/** 
		 * Request / response
		 */
		$("#graph-rr").highcharts({
			chart: {
				zoomType: 'x',
				type: 'spline'
			},

			// titles
			title: {
				text: "Request / response"
			},

			// axes
			xAxis: {
				type: 'datetime',
				crosshair: true,
				title: {
					text: 'Date'
				},
                events: {
                    setExtremes: syncExtremes
                },

			},
			yAxis: [
				{
					title: {
						text: 'Matches (#)'
					}
				},
				{
					title: {
						text: 'Response time'
					},
					labels: {
						format: '{value} ms'
					},
					opposite: true
				}
			],
			tooltip: {
				shared: true
			},
			legend: {
				enabled: true
			},
            plotOptions: {
                area: {
                    fillColor: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                        ]
                    },
                    marker: {
                        radius: 2
                    },
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 1
                        }
                    },
                    threshold: null
                }
            },

            series: requestResponse
		});



		/** 
		 * Total requests
		 */
		$("#graph-tr").highcharts({
			chart: {
				zoomType: 'x',
				type: 'area'
			},

			// titles
			title: {
				text: "Total requests"
			},

			// axes
			xAxis: {
				type: 'datetime',
				crosshair: true,
				title: {
					text: 'Date'
				},
                events: {
                    setExtremes: syncExtremes
                },

			},
			yAxis: {
				title: {
					text: 'Requests (#)'
				}
			},

			legend: {
				enabled: false
			},
            plotOptions: {
                area: {
                    fillColor: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                        ]
                    },
                    marker: {
                        radius: 2
                    },
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 1
                        }
                    },
                    threshold: null
                }
            },

            series: [
            	{
            		name: 'Total requests',
            		data: tr
            	}
            ]
		});

		var pprSeries = [];

		for(var region in playersProcessed) {
			pprSeries.push(playersProcessed[region]);
		}

		$("#graph-ppr").highcharts({
			chart: {
				zoomType: 'x',
				type: 'spline'
			},

			// titles
			title: {
				text: "Players processed"
			},
			subtitle: {
				text: "how many players each proc. instance has processed"
			},

			// axes
			xAxis: {
                crosshair: true,
				type: 'datetime',
				title: {
					text: 'Date'
				},
	            events: {
	                setExtremes: syncExtremes
	            },
			},
			yAxis: {
        		showRects: true,
				title: {
					text: 'Players (#)'
				},
				min: 0
			},

			legend: {
				// enabled: false
			},
            plotOptions: {
                area: {
                    fillColor: {
                        linearGradient: {
                            x1: 0,
                            y1: 0,
                            x2: 0,
                            y2: 1
                        },
                        stops: [
                            [0, Highcharts.getOptions().colors[0]],
                            [1, Highcharts.Color(Highcharts.getOptions().colors[0]).setOpacity(0).get('rgba')]
                        ]
                    },
                    marker: {
                        radius: 2
                    },
                    lineWidth: 1,
                    states: {
                        hover: {
                            lineWidth: 1
                        }
                    },
                    threshold: null
                }
            },

            series: pprSeries
		});
	});

	// // delay
	// new Dygraph(document.getElementById("graph-delay"),
 //      delays,
 //      {
 //        labels: [ "Date", "Delay" ],
 //        showInRangeSelector: true,
 //        fillGraph: true,
 //      });

	// // mpr
	// new Dygraph(document.getElementById("graph-mpr"),
 //      mpr,
 //      {
 //        labels: [ "Date", "Matches per request" ],
 //        showInRangeSelector: true,
 //        fillGraph: true,
 //      });

	// // rr
	// new Dygraph(document.getElementById("graph-rr"),
 //      rr,
 //      {
 //        labels: [ "Date", "Requests", "Avg. fetch response time" ],
 //        showInRangeSelector: true,
 //        fillGraph: true,
 //      });

	// // tr
	// new Dygraph(document.getElementById("graph-tr"),
 //      tr,
 //      {
 //        labels: [ "Date", "Requests" ],
 //        showInRangeSelector: true,
 //        fillGraph: true,
 //      });

 //    // downtime
	// new Dygraph(document.getElementById("graph-downtime"),
 //      downtime,
 //      {
 //        labels: [ "Date", "Downtime" ],
 //        showInRangeSelector: true,
 //        fillGraph: true,
 //      });

 // 	// ppr
	// new Dygraph(document.getElementById("graph-ppr"),
 //      ppr,
 //      {
 //        labels: ["Date", "Global", "US", "EU", "Asia", "Africa", "Russia", "South America", "Australia"],
 //        showInRangeSelector: true,
 //        fillGraph: true,
 //      });

	

</script>
</body>
</html>