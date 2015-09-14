<!doctype html>
<html>
<head>
    <meta charset="UTF-8">
    <title>DotaBoards &mdash; daily Dota 2 leaderboards</title>
    <link href="http://fonts.googleapis.com/css?family=Julius+Sans+One|Open+Sans:400,800,600,300|Lato" rel="stylesheet" type="text/css">
    <link rel="stylesheet" type="text/css" href="//cdn.azuru.me/db/css/regions-primary.css" />
</head>
<body>

<div id="main">
    <div id="logo-contain">
        <div id="logo" class="hidden">
            <div class="db">DotaBoards</div>
            <div class="sub">daily Dota 2 leaderboards</div>
            <div class="buttons">
                <a href="javascript:void(0);" id="js-region-choose">choose a region</a>
                <a href="#">today on DotaBoards</a>
            </div>
        </div>
    </div><div id="hero-collage"></div>
    
    
    <div id="by">{{ App::environment() }}/{{ Config::get('app.domain') }} - Copyright © Azuru Networks 2014. <span>Dota 2 is a registered trademark of Valve Corporation.</span></div>
</div>
    
<script type="text/javascript">var __regions = {{ $regions }};</script>
<script type="text/javascript" src="//cdn.azuru.me/db/js/regions-primary.js"></script>   

<!-- TEST -->

</body>
</html>
