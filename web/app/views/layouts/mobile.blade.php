<html>
<head>
	<title>DotaBoards &mdash; daily Dota 2 leaderboards</title>
	<link rel="stylesheet" type="text/css" href="//cdn.azuru.me/apps/dotaboards/template.mobile.css" />
    <link rel='stylesheet' type='text/css' href='//cdnjs.cloudflare.com/ajax/libs/semantic-ui/0.13.0/css/semantic.min.css' />
    <link href='http://fonts.googleapis.com/css?family=Julius+Sans+One|Open+Sans:400' rel='stylesheet' type='text/css'>
    <meta name="viewport" content="width=device-width, user-scalable=no" />
	<script type="text/javascript" src="http://code.jquery.com/jquery-2.1.0.min.js"></script>
	<script type="text/javascript" src="http://cdn.azuru.me/global/js/jquery/jquery.timeago.js"></script>
	<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/semantic-ui/0.13.0/javascript/semantic.min.js"></script>
	<script>
	  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
	  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
	  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
	  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

	  ga('create', 'UA-39888846-2', 'dotaboards.com');
	  ga('send', 'pageview');

	</script>
</head>
<body>
<script>
	$(function() { 
		var meta = $("#db-meta");
		if(meta.length > 0) {
	        var lastUpdate = parseInt(meta.attr("data-last-update"));
	        $(".update").html($.timeago(lastUpdate)); 
		}
		$("#sidebar").first().sidebar('attach events', '.menu-open');
		switchBoards();
		$(window).on("hashchange", function() {
			switchBoards();
		});
	});
	function switchBoards() {
		var boards = ["#kda", "#gpm", "#xpm", "#cs", "#hd", "#td", "#c2t"];
		var to = location.hash;
		if(!to || to.length == 0 || to in boards) {
			location.hash = "#kda";
		}

		if($("#sidebar").sidebar('is open'))
			$("#sidebar").sidebar('hide');

		$("#sidebar ul li a.active").removeClass('active');
		$("#sidebar ul li a[href='" + to + "']").addClass('active');
		$(".board.active").removeClass('active');
		$(".board[data-board-name='" + to.substring(1, to.length).toUpperCase() + "']").addClass('active');
	};
</script>

<div class="ui floating thin sidebar" id="sidebar">
	<ul>
		<li><a href="#kda" class='active'>KDA</a></li>
		<li><a href="#gpm">GPM</a></li>
		<li><a href="#xpm">XPM</a></li>
		<li><a href="#cs">CS</a></li>
		<li><a href="#hd">HD</a></li>
		<li><a href="#td">TD</a></li>
		<li><a href="#c2t">C2T</a></li>
	</ul>
</div>

<div class="header">
	<div class="menu-open"><i class="icon reorder"></i></div>
	<div class="logo">DOTABoards</div>
</div>


<div class="contain">
	{{ $child }}
</div>

<div class="footer">Copyright &copy; Azuru Networks 2014. <small>Stats provided by the <strong>Steam</strong> API.</small><small>Last updated <strong class="update"></strong></small></div>


</body>
</html>