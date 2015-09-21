part of process;

class Generator {
	
	Processor process;
	List bans;
	Map<String, Map> boards;
	List<List<int>> heroPlayCounts;
//	Map _PrecisionModifier;
	
	String htmlBasic  = "";
	String htmlMobile = "";
	List<String> playersToDiscard = new List();
	
	
	/**
	 * Instantiate a new Generator.
	 */
	Generator(Processor process, [List bans, List<List<int>> heroPlayCounts]) { 
		this.process = process;
		this.bans = bans;
		this.heroPlayCounts = heroPlayCounts;
//		this._PrecisionModifier = ENV.PrecisionModifierMap;
		
		ENV.log("Instantiated generator for ${process.regionalShortcode}", type: 3);
	}
	
	
	/**
	 * Build a HTML boards string.
	 */
	Generator makeBoards(Map store, Set recordedMatches, Map playerTopAppearances) {

		ENV.log("");
		ENV.log("MakeBoards for ${this.process.regionalShortcode}", type: 1);
		
		/// Get a cached version of the current boards for rendering. ///
		this.boards = this.process.getLiveBoards();
		DateTime now = new DateTime.now();
		
		
				
		/// 					  ///
		/// Begin HTML rendering. ///
		///						  ///
		
		this.htmlBasic  = "<meta id='db-meta' data-region='${this.process.regionalShortcode}' data-last-update='${now.millisecondsSinceEpoch.toString()}' data-match-count='${recordedMatches.length}'></meta><div class='boards-section' id='today'><div class='column section-header noselect'><div class='icon-contain'><i class='trophy icon'></i></div><div class='turnt'>Today's ${this.process.locationIdentifier} leaderboards</div></div>";
		this.htmlMobile = "<meta id='db-meta' data-region='${this.process.regionalShortcode}' data-last-update='${now.millisecondsSinceEpoch.toString()}'></meta>";
		
		/// Append HTML string for each respective board. /// 
		for(int i = 0; i < this.boards.length; i++) {
			String boardName = this.boards.keys.toList()[i];
			this.renderBoardsHTML(this.boards[boardName], store, boardName, playerTopAppearances);
		}
		
		this.htmlBasic  += "</div><!-- end boards -->";
		this.htmlMobile += "</div><!-- end boards -->";
		
		ENV.log("Completed MakeBoards for ${this.process.regionalShortcode} in ${new DateTime.now().difference(now)} ", type: 4);
		
		return this;
	}
	
	
	/**
	 * Build a HTML stats string.
	 */
	Generator makeStats(Map<String, String> statMap, Map<int, int> heroPlaysMap) {
		
		this.htmlBasic += "<!-- Starting stats... --><div class='column'><div class='board' id='mod'><div class='first'><h1 class='reset'>Average stats needed <small>to reach the boards</small></h1></div><div id='scroll-wrapper'><ul class='rest reset'>";
		
		for(String board in (ENV.Boards).keys.toList()) {
			String value = (double.parse(statMap[board]) > 1000) ? (ENV.util.intToShort(double.parse(statMap[board])) + "k") : statMap[board];
			this.htmlBasic += "<li><span>${ENV.BoardNames[board.toUpperCase()][0]}</span><div class='label'>$value</div></li>";
		}
		
		this.htmlBasic += "</ul><!--rest--></div><!--#scroll-wrapper for stats section--></div><!--.board--></div><!--.column--><div class='column'><div class='board'><div class='first'><h1 class='reset'>Hero popularity <small>in order of appearances on the boards</small></h1></div><div id='scroll-wrapper'><ul class='rest reset'>";
		
		for(int heroID in heroPlaysMap.keys.toList()) {
			this.htmlBasic += "<li><img src='//cdn.dota2.com/apps/dota2/images/heroes/${ENV.Heroes[heroID.toString()][0]}_sb.png' /><span>${ENV.Heroes[heroID.toString()][1]}</span><div class='label'>${heroPlaysMap[heroID]}</div></li>";							 		
		}
		
		this.htmlBasic += "</ul></div></div></div><!-- Ending stats... -->";
		return this;
	}
	
	
	/** 
	 * Render the HTML for this specific board.
	 */
	void renderBoardsHTML(Map board, Map store, String boardName, Map topAppearances) {
		
		ENV.log("");
		ENV.log("Rendering boards HTML for ${this.process.regionalShortcode}-$boardName:", type: 2);
		ENV.log("...${board['raw'].length} on boards", type: 4);
//		ENV.log(JSON.encode(this.bans), type: 3);
		
		/// 					  		///
		/// Base HTML for this board. 	///
		///						  		///
		this.htmlBasic  += "<div class='column'><div class='board ui transition hidden' data-board-name='${boardName}'>"; 
		this.htmlMobile += "<div class='board' data-board-name='${boardName}'>";
		
		int position  = 1;
		int discarded = 0;
		bool hasFinished = false;
		
		
		/// 					  			///
		/// Loop through players in board. 	///
		///						  			///
		for(List<dynamic<String, int>> player in board["raw"]) {
			
			try {
				Map<String, String> user 		= store[ player[0] ];
				Map<String, dynamic> detailed 	= this.boards[boardName]["det"][ player[0] ]; 
						
				/// If user is in the store (safety precaution), detailed data was on boards ///
				/// and the player isn't banned (does this work?)							 ///
				if( (user != null) && (detailed != null) && (this.bans.contains(int.parse(player[0])) == false)) {
					
					/// Lots of player information! ///
					dynamic<double, String> value	= player[1] / ENV.PrecisionModifierMap[boardName];
					String name 					= user["name"].length > 0 ? this.htmlEntities(user["name"]) : "<em>no name provided</em>";
					String id64						= ENV.util.to64(int.parse(player[0])).toString();
					String pic 						= user['pic'];
					
					String realBoardName 	= ENV.BoardNames[boardName][1];
					String playerDetails 	= "<span>${detailed['kills']} kills</span> &nbsp; <span>${detailed['deaths']} deaths</span> &nbsp; <span>${detailed['assists']} assists</span>";
					String matchData		= " data-player-id='${player[0]}' data-match-id='${detailed['match']}'";
					String location			= ENV.util.getCluster( detailed['loc'] );
					String heroID 			= detailed['hero'].toString();
					int heroPlayIndex		= this.getHeroPlayIndex(detailed['hero']);
					String playCount;
					String popularity 		= (heroPlayIndex + 1).toString() + ENV.util.intAddSuffix(heroPlayIndex + 1);
					
					if(heroPlayIndex == -1) {
						ENV.log("WARNING: hero play index missing for $heroID", type:4, level: 2);
						playCount = "?";
					} else {
						playCount = ENV.util.intToShort(this.heroPlayCounts[heroPlayIndex][1]) + "k";
					}
					
					String heroPopup		= "class='popup' data-title='${ENV.Heroes[heroID][1]}' data-content='Popularity: ${popularity} (${playCount} plays)' data-position='bottom center'";
					
					ENV.log("#${position} ${name} [${player[0]}]: ${value} as ${ENV.Heroes[heroID][1]} ($popularity)", type: 3, level: 0);
					
					/// Set variables based on board type. ///
					switch(boardName) {
						case "KDA":
							value = value.toStringAsFixed(2);
							break;
							
						case "GPM":
							value = value.toStringAsFixed(0);
							String goldEarned = ENV.util.intToShort( (detailed['duration'] / 60) * detailed['gpm'] );
							playerDetails = "<span>${goldEarned}k gold earned</span> <span>over ${ENV.util.secondsToTime(detailed['duration'])}</span>";
							break;
						
						case "XPM":
							value = value.toStringAsFixed(0);
							break;
							
						case "CS":
							value = value.toStringAsFixed(2);
							playerDetails = "<span>${detailed['last_hits']}</span>-<span>${detailed['denies']}</span> <span>over ${ENV.util.secondsToTime(detailed['duration'])}</span>";
							break;
							
						case "HD": 
						case "TD":
							value = ENV.util.intToShort(value) + "k";
							break;
							
						case "C2T":
							value = value.toStringAsFixed(2);
							String help = ENV.util.intToShort( detailed['tower_damage'] + detailed['hero_damage'] );
							playerDetails = "<span>${help}k total damage</span> &nbsp; <span>${ENV.util.intToShort(detailed['hero_healing'])}k healing</span>";
	                        break;
	                        
						default: 
							value = value.toStringAsFixed(2);
							break;
							
					}
					
			
					
					/// Determine user's position in respective board. ///
					if(position == 1) {
						
						/// Handle the 1st place user. ///
						int appearancesCount;
						try {
							
							if(topAppearances.containsKey(player[0])) {
								/*ENV.log("Player was found in topAppearances");
								ENV.log("Player0 is string: ${player[0] is String}");
								ENV.log("First key is String: ${topAppearances.keys.first is String}");
								ENV.log("TopAppearances:player0 is int: ${topAppearances[player[0]] is int}");*/
								appearancesCount = topAppearances[player[0]];
							} else appearancesCount = 1;
						
							if(pic == null) 
								pic = "http://cdn.azuru.me/apps/dotaboards/none.png";
							else 
								pic = "http://media.steampowered.com/steamcommunity/public/images/avatars/" + pic;
							
							this.htmlBasic  += "<div class='first' id='player-expand-details'${matchData} data-player-id-64='${id64}' data-player-name='${name}' data-player-appearances='${appearancesCount.toString()}' data-profile-pic='${pic}'><div class='ui instant fade reveal'><img class='hidden content' src='${pic}' /><img class='visible content' src='//cdn.azuru.me/apps/dotaboards/heroes/[${heroID}].png' /></div><div class='stats'><strong title='${name}'><span>#1</span> ${name}</strong><div class='info detailed'>${playerDetails}</div></div><div class='tag'>${realBoardName}</div><div class='tag value'>${value.toString()}</div></div>";
							this.htmlMobile += "<div class='first'><img src='//cdn.azuru.me/apps/dotaboards/heroes/[${heroID}].png' /><div class='stats'><strong><span>#1</span> ${name}</strong><div class='info'><strong>${value}</strong></div></div><div class='tag'>${realBoardName}</div></div>";
	
							
						} catch(e) {
							ENV.log(e.toString(), type: 4);
							throw e;
						}
					} else {
						
						/// Handle users 2-100. ///
						if(position == 2) {
							this.htmlBasic 	+= "<div id='scroll-wrapper'><ul class='rest reset'>";
							this.htmlMobile += "<ul class='rest'>";
						}
						
						this.htmlBasic  += "<li${matchData}><img src='//cdn.dota2.com/apps/dota2/images/heroes/${ENV.Heroes[heroID][0]}_sb.png' ${heroPopup}/><span title='${name}'><span>#${position}</span> ${name}</span><div class='label'>${value}</div><div class='detailed'><span class='location-buff' data-loc='${location}'>${location}</span>${playerDetails}</div></li>";
	                    this.htmlMobile	+= "<li><img src='//cdn.dota2.com/apps/dota2/images/heroes/${ENV.Heroes[heroID][0]}_sb.png' /><span><span>#${position}</span> ${name}</span><div class='label'>${value}</div></li>";
	                    					
						if(position == (board["raw"].length - discarded)) {
							hasFinished = true;
							this.htmlBasic  += "</ul></div> <!-- hasFinished:1-->";
							this.htmlMobile += "</ul></div>";
						}
					}
					
					position++;
					
				} else {
					
					if(position == (board["raw"].length - discarded)) {
						hasFinished = true;
						this.htmlBasic  += "</ul></div> <!-- hasFinished:2 -->";
						this.htmlMobile += "</ul></div>";
					} else discarded++;
	
					/// Player was banned and/or user info doesnt exist, 
					/// so we should remove them from the boards to
					/// make room for other people
					this.playersToDiscard.add( player[0] );
					ENV.log("Discarding ${player[0]} with: user(null)=${user==null} detailed(null)=${detailed==null}, banned=${this.bans.contains(player[0])}", type: 3);
					
				}
			} catch(e, stack) {
				ENV.log("ERROR:", type: 4);
				ENV.log("$e \n", type: 3);
				ENV.log("$stack", type: 3);
				continue;
			}
		
		}
		
		if(hasFinished == false) {
			this.htmlBasic 	+= "</div><!-- overridden board close-->";
			this.htmlMobile	+= "</div>";
		}
		
		this.htmlBasic += "</div><!--[end .board]--></div><!--[end .column]-->";
		
		ENV.log("...done rendering ${boardName}", type: 3);
		
	}
	
	
	/**
	 * Parse htmlentities from given string.
	 */
	String htmlEntities(String str) => str.replaceAll(new RegExp(r"&"), '&amp;').replaceAll(new RegExp(r"<"), '&lt;').replaceAll(new RegExp(r">"), '&gt;').replaceAll(new RegExp("\""), '&quot;');
	

	/**
	 * Get the index of (hero) in the hero plays list.
	 */
	int getHeroPlayIndex(int hero) => this.heroPlayCounts.indexOf( 
		this.heroPlayCounts.firstWhere( 
			(element) => element[0] == hero 
		, orElse: () {
			return -1;
		})
	);
		
}