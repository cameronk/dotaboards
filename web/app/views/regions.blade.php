<html>
<head>
    <title>DotaBoards &mdash; select a region</title>
    <link href="http://fonts.googleapis.com/css?family=Lato" rel="stylesheet" type="text/css" />
    <script type="text/javascript" src="http://code.jquery.com/jquery-2.1.0.min.js"></script>
    <style>
        body {
            padding: 0px;
            margin: 0px;
            background: url(http://cdn.azuru.me/apps/dotaboards/dark_mosaic.png);
            overflow: hidden;
        }

        .map {
            padding: 0px;
            margin: 0 auto;
            width: 1920px;
            height: 1015px;
            background: url(http://cdn.azuru.me/apps/dotaboards/map.png);
            background-size: 100% 100%;
            background-repeat: no-repeat;
            opacity: 0.05;
        }
            .region {
                position: absolute;
                border: 3px solid #777;
                border-radius: 999px;
                opacity: 0;
                -webkit-transition: all 450ms ease-in-out;
                -moz-transition: all 450ms ease-in-out;
                -ms-transition: all 450ms ease-in-out;
                -o-transition: all 450ms ease-in-out;
                transition: all 450ms ease-in-out;
                margin-top: 40px;
            }
                .region.visible {
                    opacity: 0.125;
                    margin-top: 0px;
                }
                .region#us {
                    width: 300px;
                    height: 300px;
                    top: 120px;
                    left: 210px;
                }
                .region#south-america {
                    width: 400px;
                    height: 400px;
                    top: 400px;
                    left: 330px;
                }
                .region#eu {
                    width: 290px;
                    height: 290px;
                    top: 20px;
                    left: 750px;
                }
                .region#russia {
                    width: 500px;
                    height: 500px;
                    top: -195px;
                    left: 1050px;
                }
                .region#asia {
                    width: 320px;
                    height: 320px;
                    top: 200px;
                    left: 1220px;
                }
                .region#china {
                    width: 220px;
                    height: 220px;
                    top: 220px;
                    left: 1320px;
                }
                .region#africa {
                    width: 350px;
                    height: 350px;
                    top: 370px;
                    left: 820px;
                }
                .region#aus {
                    width: 300px;
                    height: 300px;
                    top: 505px;
                    left: 1435px;
                }
        
        .select-box {
            width: 500px;
            height: 600px;
            margin: 0 auto;
            position: absolute;
            top: 50%;
            left: calc(50% - 250px);
            transform: translateY(-50%);
            background: rgba(255,255,255,0.05);
            border-radius: 3px;
        }
            .select-box ul {
                list-style: none;
                font-size: 0px;
                padding: 0px;
                margin: 0px;
            }
                .select-box ul li {
                    display: inline-block;
                    box-sizing: border-box;
                    width: 250px;
                    height: 150px;
                    vertical-align: top;
                    font-size: 30px;
                    font-family: "Lato", sans-serif;
                    text-align: center;
                }
                .select-box ul li:hover {
                    box-shadow: inset 0px 0px 50px rgba(0,0,0,0.1), inset 0px 0px 25px rgba(0,0,0,0.3);
                    cursor: pointer;
                }
                .select-box ul li img {
                    display: block;
                    margin: 0 auto;
                    margin-top: 17px;
                }
                .select-box ul li span {
                    display: block;
                    line-height: 30px;
                    color: #ccc;
                }
    </style>
</head>
<body>
    
<div class="region" id="us"></div>
<div class="region" id="south-america"></div>
<div class="region" id="eu"></div>
<div class="region" id="russia"></div>
<div class="region" id="asia"></div>
<div class="region" id="africa"></div>
<div class="region" id="aus"></div>
   
<div class="map"></div>    

<div class="select-box">
    <ul>
        <a href="http://us.dotaboards.com"><li data-region="us">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/us.png" />
                <span>United States</span>
            </div>
        </li></a>
        <a href="http://eu.dotaboards.com"><li data-region="eu">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/eu.png" />
                <span>Europe</span>
            </div>
        </li></a>
        <a href="http://aus.dotaboards.com"><li data-region="aus">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/aus.png" />
                <span>Australia</span>
            </div>
        </li></a>
        <a href="http://russia.dotaboards.com"><li data-region="russia">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/russia.png" /> 
                <span>Russia</span>
            </div>
        </li></a>
        <a href="http://asia.dotaboards.com"><li data-region="asia">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/asia.png" />
                <span>Asia</span>
            </div>
        </li></a>
        <a href="http://africa.dotaboards.com"><li data-region="africa">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/africa.png" />
                <span>South Africa</span>
            </div>
        </li></a>
        <a href="http://south-america.dotaboards.com"><li data-region="south-america">
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/south-america.png" />
                <span>South America</span>
            </div>
        </li></a>
        <a href="http://global.dotaboards.com"><li>
            <div class="inner">
                <img src="http://cdn.azuru.me/apps/dotaboards/flags/64/global.png" />
                <span>Worldwide</span>
            </div>
        </li></a>
    </ul>
</div> 
<script>
    $(function() {
        $(".select-box ul li").hover(function() {
            $(".region#" + $(this).attr('data-region')).addClass('visible'); 
        }, function() {
            $(".region#" + $(this).attr('data-region')).removeClass('visible');
        });
    });
</script>
</body>
</html>