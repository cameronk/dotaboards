<html>
<head>
    <title>DotaBoards &mdash; daily Dota 2 leaderboards</title>
    <meta name="description" content="DotaBoards tracks the top statistical performances by Dota 2 players from around the world.">
    <link href='http://fonts.googleapis.com/css?family=Julius+Sans+One|Open+Sans:400,800,600,300|Lato' rel='stylesheet' type='text/css'>
    <link rel='stylesheet' type='text/css' href='//cdnjs.cloudflare.com/ajax/libs/semantic-ui/0.13.0/css/semantic.min.css' />
    <link rel='stylesheet' type='text/css' href='http://cdn.azuru.me/apps/dotaboards/template.css' />
    <link rel='stylesheet' type='text/css' href='http://cdn.azuru.me/apps/dotaboards/scrollbar.css' />
    <script type="text/javascript" src="http://code.jquery.com/jquery-2.1.0.min.js"></script>
    @if(isset($css))
        @foreach($css as $file)
            <link rel='stylesheet' type='text/css' href='http://cdn.azuru.me/apps/dotaboards/{{ $file }}.css' />
        @endforeach
    @endif
    <link rel="icon" type="image/png" href="http://dotaboards.com/favicon.ico" />
</head>
<body class="reset">

<?php
    $regions = [ 
        "global" => "planet Earth", 
        "us" => "the United States", 
        "eu" => "Europe", 
        "asia" => "Asia", 
        "africa" => "Africa", 
        "russia" => "Russia",
        "south-america" => "South America",
        "aus" => "Australia"
    ];
    $split = explode(".", substr(Request::url(), 7));
    $region = $split[0];
    $site = Site::where('id', '0')->first(); 
?>

@if($site->steam_online == 0)

    <script>
    $(function() { 
        $("#steam-down-modal").modal('show'); 
        $("a.signin").attr('disabled', true);
    });
    </script>
    <div class="ui small modal" id="steam-down-modal">
        <i class="close icon"></i>
        <div class="header"><i class='warning icon'></i> Uh oh!</div>
        <div class="content">
            <p>Steam went down about <i>{{{ $site->steam_down_at->diffForHumans() }}}</i>. <br/><br/><strong>DotaBoards</strong> is still online, but new matches will not be recorded until it returns.</p>
        </div>
        <div class="actions">
            <div class="ui green button">Got it!</div>
        </div>
    </div>

@elseif(!Request::cookie('region') && !Session::has('asked.' . $region)) 

    <script>
        $(function() {
            $("#set-region-modal")
                .modal({
                    closable: false,
                    onApprove: function() {
                        $.post("/region/set", { _token: "{{ csrf_token() }}", region: "{{ $region }}" }, function(response) {
                            if(response.success == true) {
                                $("#set-region-modal")
                                    .modal('hide')
                                ;
                            }
                        });
                    },
                    onDeny: function() {
                        $.post("/region/nope", { _token: "{{ csrf_token() }}", region: "{{ $region }}" }, function(response) {
                            if(response.success == true) {
                                $("#set-region-modal")
                                    .modal('hide')
                                ;
                            }
                        });
                    }
                })
                .modal('show');
        });
    </script>
    <div class="ui small basic modal" id="set-region-modal">
        <i class="close icon"></i>
        <div class="header"></div>
        <div class="content">
            <div class="left">
                <p>Would you like to make <strong>{{ $regions[$region] }}</strong> your preferred region? We'll remember this region next time you visit DotaBoards - you can change it at any time by clicking the flag in the header controls.</p>
            </div>
        </div>
        <div class="actions">
            <div class="ui green approve button">Sure!</div>
            <div class="ui red deny button">No thanks...</div>
        </div>
    </div>

@elseif(!Session::has('user.warning'))

    <?php Session::push('user.warning', 'true'); ?>
    <script>
    $(function() { $("#warning-modal").modal('show'); });
    </script>
    <div class="ui small modal" id="warning-modal">
        <i class="close icon"></i>
        <div class="header"><i class='warning icon'></i> Heads up!</div>
        <div class="content">
            <p><strong>DotaBoards</strong> is currently in <em>beta</em>. We're still refining our algorithms and calculation methods &mdash; if you believe a certain player should have reached the boards, please don't hesitate to <a href="http://azuru.me/contact" class="link">shoot us a message</a>.</p>
        </div>
        <div class="actions">
            <div class="ui green button">Got it!</div>
        </div>
    </div>

@endif

<div class="ui small basic modal" id="not-found-modal">
    <i class="close icon"></i>
    <div class="header">Player not found.</div>
    <div class="content">
        <div class="left">
            <p>That player currently isn't on the boards! <strong>DotaBoards</strong> updates roughly every 20 minutes, so check back soon!</p>
        </div>
    </div>
    <div class="actions">
        <div class="ui button cancel">Close</div>
    </div>
</div>

<div class="ui small basic modal" id="appearances-modal">
    <i class="close icon"></i>
    <div class="header" id="player-name"></div>
    <div class="content" style="padding-top: 10px; padding-bottom: 10px;">
        <div class="left" style="width: 184px;">
            <img class="ui rounded image" src="" id="player-profile-pic" />
        </div>
        <div class="right">
            <div class="ui large pointing left label"><strong id="appearances"></strong> <span id="appearances-word"></span></div>
        </div>
    </div>
    <div class="actions">
        <a href="http://steamcommunity.com" id="steam-link" target="_blank" style="float: left;"><div class="ui black icon button"><i class="user icon"></i> Steam profile</div></a>
        <a href="http://dotabuff.com" id="dotabuff-link" target="_blank"><div class="ui red icon button"><i class="globe icon"></i> DotaBuff</div></a>
    </div>
</div>

<div class="ui modal" id="about-modal">
    <i class="close icon"></i>
    <div class="header">About DotaBoards</div>
    <div class="content">
        <div class="left">
            <p><strong>DotaBoards</strong> pools thousands of matches from the official <strong>Dota 2</strong> API daily, scanning each for potential board-achieving players. Our algorithms for determining a player's "score" on each board are as follows:</p>
        </div>
        <div class="right" style="width: 65%;">
        <div class="ui relaxed divided list">
            <a class="item">
                <div class="ui red horizontal label">KDA</div>
                <img src="http://cdn.azuru.me/apps/dotaboards/kda.png" style="float:right;height: 40px"/>
            </a>
            <a class="item">
                <div class="ui purple horizontal label">CS</div>
                <img src="http://cdn.azuru.me/apps/dotaboards/cs.png" style="float:right;"/>
            </a>
            <a class="item">
                <div class="ui red horizontal label">C2T*</div>
                <img src="http://cdn.azuru.me/apps/dotaboards/c2t.png" style="float:right; height: 31px"/>
            </a>
            <a class="item">
                <p>All other boards available on DotaBoards use data processed by Dota 2 and provided through the API.</p>
                <small><sup>*</sup> C2T stands for "Credit to Team"</small>
            </a>
        </div>
        </div>
    </div>
    <div class="actions">
        <div class="ui button cancel">Close</div>
    </div>
</div>


<!-- Begin page content. -->
<div class="block-header">
    <div id="logo-contain">
        <a href="//{{ Config::get('app.domain') }}"><div class="logo noselect t200"><strong></strong>DotaBoards</div></a>
        <div class="nav notifs noselect">
            <div class="beta">BETA</div>
            @if(@$index == true)
                <div class="last-update"><i class="time icon"></i> <span>Calculating...</span></div>
                <div class="match-count"><i class="archive icon"></i> <span>No</span> matches today</div>
            @endif
        </div>
        <div class="nav main noselect">
            @if(@$index == true)
                <div class="region action ap-ct" data-content="Change region" data-position="bottom center">
                    <a href="{{ url('region/back') }}"><img src="http://cdn.azuru.me/apps/dotaboards/flags/64/{{ $region }}.png" /></a>
                </div>
                <div class="stats action"><a href="{{ url('stats') }}"><i class="tasks icon"></i> Statistics</a></div>
                <div class="expand action"><i class="expand icon"></i> <span>Expand<span></div>
                <div class="about action"><i class="question mark icon"></i> How it works</div>
            @endif
        </div>
        <div class="user-area">
            @if(Auth::check()) 
                <div data-steam32="{{ Auth::user()->steam32 }}" class="user-info">
                    <span class="name">{{{ Auth::user()->persona }}} 
                    <?php
                        $c = "0";
                        $t = "You have never appeared on the boards.";
                        $a = Appearance::where('id', Auth::user()->steam32)->first();
                        if(!is_null($a)) {
                            $c = $a->count;
                            $t = "You last appeared on the boards " . $a->updated->format("M j, \a\t g:i A");
                        }
                    ?>
                        <span class="ap-ct popup" data-content="{{ $t }}" data-position="top left">{{ $c }}</span>
                    </span>
                    <span class="controls"><a href="#{{ Auth::user()->steam32 }}">find me</a> &mdash; <a href="/signout">sign out</a></span>
                </div>
                <a href="#{{ Auth::user()->steam32 }}">
                    <img class="user-pic" src="{{{ Auth::user()->avatar }}}" />
                </a>
            @else 
                <!-- Not signed in -->
                <a href="http://dotaboards.com/signin" class="signin"><div class="signin-button t200"><i class="sign in icon noselect"></i> Sign in with Steam</div></a>
            @endif
        </div>
    </div>
</div>
<div class="block-body">
    {{ $child }}
</div>
<div class="block-footer">
    <div class="ui two column grid">
        <div class="row">
            <div class="column">
                <div class="copyright">Copyright &copy; Azuru Networks 2014-2015. <small>Dota 2 is a registered trademark of Valve Corporation.</small></div>
            </div>
            <div class="column">
                <div class="azuru-watermark"><a href="http://azuru.me/" target="_blank">Azuru.</a></div>
            </div>
        </div>
    </div>
</div>
    
<script type="text/javascript" src="http://cdn.azuru.me/global/js/jquery/jquery.timeago.js"></script>
<script type="text/javascript" src="http://cdn.azuru.me/global/js/jquery/jquery.scrollTo.min.js"></script>
<script type="text/javascript" src="http://cdn.azuru.me/global/js/jquery/jquery.easing.1.3.js"></script>
<script type="text/javascript" src="//cdnjs.cloudflare.com/ajax/libs/semantic-ui/0.13.0/javascript/semantic.min.js"></script>
<script type="text/javascript" src="http://cdn.azuru.me/global/js/jquery/perfect-scrollbar/perfect-scrollbar-0.4.10.with-mousewheel.min.js"></script>
<script type="text/javascript" src="http://cdn.azuru.me/apps/dotaboards/db.js"></script>
<script>
  (function(i,s,o,g,r,a,m){i['GoogleAnalyticsObject']=r;i[r]=i[r]||function(){
  (i[r].q=i[r].q||[]).push(arguments)},i[r].l=1*new Date();a=s.createElement(o),
  m=s.getElementsByTagName(o)[0];a.async=1;a.src=g;m.parentNode.insertBefore(a,m)
  })(window,document,'script','//www.google-analytics.com/analytics.js','ga');

  ga('create', 'UA-39888846-2', 'dotaboards.com');
  ga('send', 'pageview');
</script>
</body>
</html>