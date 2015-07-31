library dispatcher;

import "dart:async";
import "dart:convert";
import "dart:io";

import "package:http/http.dart" as HTTP;

import "../util/util.dart";
import "../database/pool.dart";
import "../processor/processor.dart";

part "dispatcherror.dart";

class Dispatcher {
	
	List bans;
	int DaemonLifetimeRecordedCount = 0;
	Set recordedMatches 		= new Set();
	int lastMatchSequenceNum;
	int lastRetrievedMatchCount = 0;
	bool waitingToPush 			= false;
	bool waitingToClean			= false;
	
	DateTime steamDownStartTime;
	int steamPingAttempts 		= 0;
	
	Util util;
	QueryHelper queries;
	Processor process;
	Monitor monitor;
	
	Map<String, Processor> regionalProcessors = new Map();
	
	Statistics stats;
	
	/// Directories are relative to the "daemon" directory ///
	final String _key 			= "E03B7DAF68C03DFF4745BF4213BC8672";
	final int _privatePlayer 	= 4294967295;
	
	Timer _pushTimer;
	Timer _cleanTimer;
	Timer fetchRestartTimer;
	DateTime lastClean = new DateTime.now();
	
	
	/**
	 * Instantiate a new dispatcher object.
	 */
	Dispatcher([List bans, QueryHelper queries]) {
		
		this.bans = bans;
		this.queries = queries;
		this.monitor = new Monitor();
		
		this.instantiateProcessors();
		
		this.util = new Util(); 
		this.stats = new Statistics(this.queries);
		
		ENV.log("\n\n\n\n");
		ENV.log("STARTING", type: 1);
		this.getLatestMatchSeqNum().then((num) {
			this.lastMatchSequenceNum = num;
			this.start();
		});
		
	}
	
	
	/**
	 * Instantiate processor objects based on a region map.
	 */
	void instantiateProcessors() {
		
		/// Clear processors we've already used ///
		if(regionalProcessors.length > 0)
			regionalProcessors.clear();
		
		this.process = new Processor("global", "worldwide");
		
		for(String region in (ENV.RegionMap).keys.toList()) {
			ENV.log("Instantiating: ${region}", type: 4);
			Processor newProcessor = new Processor(region, (ENV.RegionIdentifiers)[region]);
			this.regionalProcessors[region] = newProcessor;
		}
		
	}
	
	
	/**
	 * Begin the first fetch, initialize timers.
	 */
	void start() {
		ENV.log("at ${this.lastMatchSequenceNum.toString()}", type: 4);
		/// Start loops ///
		
		this.fetch();
		this.initTimers();
	}
	
	
	/**
	 * Construct timers.
	 */
	void initTimers() {
		this._pushTimer = new Timer.periodic(const Duration(seconds: 60), (_) {
			DateTime now = new DateTime.now();
			if([0, 20, 40].contains(now.minute)) {
				this.waitingToPush = true;
			}
		});
		this._cleanTimer = new Timer.periodic(const Duration(seconds: 60), (_) {
			DateTime now = new DateTime.now();
			if( (now.hour == 0 && now.minute == 0) || ( this.lastClean.difference(new DateTime.now()).inHours >= 24 )) {
				this.waitingToPush = true;
				this.waitingToClean = true;
			}
		});
	}
	
	
	/**
	 * Destroy active timers.
	 */
	void destroyTimers() {
		this._pushTimer.cancel();
		this._cleanTimer.cancel();
	}
	
	
	/**
	 * Run the fetch loop.
	 */
	void fetch () {
		if(this.waitingToPush == true) {
			this.waitingToPush = false;
			this.push();
		} else {
			DateTime fetchStart = new DateTime.now();
			ENV.log("${this.lastMatchSequenceNum} [${fetchStart.toString()}] >");
			
			HTTP.get("https://api.steampowered.com/IDOTA2Match_570/GetMatchHistoryBySequenceNum/v0001/?key=${this._key}&matches_requested=25&start_at_match_seq_num=${this.lastMatchSequenceNum.toString()}")
				.then((response) {
					ENV.log("==> ${(new DateTime.now()).difference(fetchStart).inMilliseconds}ms", type: 3);
					if(response.statusCode == 200) {
						
						this.requestSuccess();
						this.fetchRestartTimer.cancel();
						
						//ENV.log("BODY: ${response.body.substring(0, 10)} ...");
						final Map result = JSON.decode(response.body)["result"];
						int disqualifiedMatches = 0;
						
						if(result["status"] == 1 && result["matches"] != null) {
						
							final List matches = result["matches"];
							ENV.log("Got ${matches.length} matches.", type: 3);
							
							/// -1: Loop through all returned matches. ///
							for(Map match in matches) {
							
								/// 0: Check if we've already recorded this match ///
								if(!this.recordedMatches.contains(match['match_seq_num'])) {
									
									/// 1: Check for lobby_type, game mode, AND match passes validity filter ///
									if( [0, 5, 6, 7].contains(match["lobby_type"]) && [1, 2, 3, 4, 5, 8, 12, 16, 17].contains(match["game_mode"]) && this.MVF(match) == true ) {
										
										
										/// Match is valid. Add to recorded matches. ///
										this.recordedMatches.add(match["match_id"]);
										
										/// Let's go ahead and run the monitor for this match.
										this.monitor.match(match);
										
										
										Map players = new Map();
										
										/// 2: Loop through all players in this match. ///
										for(Map player in match['players']) {
											
											/// 2.1: Check if player meets basic criteria. ///
											if( (player['account_id'] != this._privatePlayer) && player['leaver_status'] == 0 && (ENV.Heroes).containsKey(player['hero_id'].toString()) && !this.bans.contains(player['account_id']) ) {
												
												players[player['account_id']] = this.buildPlayerMap(player, match);
												
											}
											
										}
										
										/// 3: Check if we found any players in this match ///
										if(players.length > 0) {
											
											queries.pushMatch({
												"id": match["match_id"],
												"seqnum": match["match_seq_num"],
												"cluster": match["cluster"],
												"gamemode": match["game_mode"],
												"radiant_win": match["radiant_win"],
												"completed_at": new DateTime.fromMillisecondsSinceEpoch((match["start_time"] * 1000) + (match["duration"] * 1000)).toString()
											});
											
											/// 3.1: Loop through all found players and process ///
											for(Map player in players.values) {
											
												/// Send this player to the global processor. ///
												this.process.player(player);
												
												/// Dispatch this player to their specified region. ///
												String region = ENV.RegionMapReverse[ this.util.getCluster(player['loc']) ];
												
												if(regionalProcessors.containsKey(region)) {
													ENV.log("${player['id']} --> $region", type: 3);
													(this.regionalProcessors[region]).player(player);
												}
												
											}
											
										} else {
											ENV.log("No valid players in ${match['match_seq_num']}.", type: 3);
										}
										
									} else disqualifiedMatches++;
								
								} else {
									disqualifiedMatches++;
									ENV.log("Already processed match ${match['match_seq_num']}.", type: 4);
								}
								
							}
							
							ENV.log("Done processing ${this.lastMatchSequenceNum}. $disqualifiedMatches/${matches.length} disqualified", type: 3);
							this.lastMatchSequenceNum = matches.last["match_seq_num"] + 1;
							ENV.log("Looping back to ${this.lastMatchSequenceNum}...", type: 3);
							
							//(this.process.saveBoards()).then((_) {
								int difference = (new DateTime.now()).difference(fetchStart).inMilliseconds;
								new Timer(new Duration(milliseconds: (2000 - difference)), () => this.fetch());
							//});
						} else throw new DispatchError("Matches == null");
					} else throw new DispatchError("Received ${response.statusCode} from API.");
				})
				.timeout( (new Duration(seconds: 30)), onTimeout: () { 
					ENV.log("WARNING: Timed out...", type: 3);
					throw new DispatchError("Timed out.");
				})
				.catchError((Error error) {
					ENV.log("Caught a request error for fetching from ${this.lastMatchSequenceNum}.", type: 3);
					ENV.log("Running another loop in 15 seconds...", type: 3);
					this.requestFailure(error.toString());
					this.fetchRestartTimer = new Timer(const Duration(seconds: 15), () => this.fetch());
				});
		}

	}
	
	
	/**
	 * Run the push loop.
	 */
	void push () {
		
		ENV.log("Beginning push.", type: 1);
		
		Set currentRecordedMatches = this.recordedMatches;
		
		void done() {
			this.stats.recordPush(currentRecordedMatches, this.lastRetrievedMatchCount, this.process.getCumulativeStatistics()).then((_) {
				
				
				/// Run the monitor ///
				this.monitor.push();
				
				this.util.text("Pushed ${currentRecordedMatches.length} @ ${new DateTime.now().toLocal()}.");
				
				this.lastRetrievedMatchCount = currentRecordedMatches.length;
				this.process.resetCumulativeStatistics();
				
				if(this.waitingToClean == true) {
					this.waitingToClean = false;
					this.clean();
				} else this.fetch();
				
			});
		};
		
		
		
		/// Let's get started.					///
		/// First step is to retrieve the bans 	///
		/// then we'll move on to other processing.
		this.queries.retrieveBans().then((bans) {
			this.bans = bans;
			
			/// Now get the hero play counts list. ///
			this.queries.retrieveHeroPlayCounts().then((heroPlayCounts) {
				
				ENV.log("Got hero play counts with length ${heroPlayCounts.length}", type: 4);
				
				/// Sort hero play counts by number of plays ///
				heroPlayCounts.sort((a, b) => (b[1] - a[1]));
				
				/// Parse users.json file. ///
				this.grab(ENV.StorageDirectory + "users.json").then((data) {
	
					ENV.log("Already got ${data.length} users", type: 4);
					
					List alreadySaved = data.keys.toList();
					
					/// Get IDs from the global processor ///
					Map<int, int> idMap = this.process.get64BitIDList(alreadySaved); /// [id64]: [id32]
					
					/// Get IDs from each regional processor ///
					for(String region in (ENV.RegionMap).keys.toList()) {
						Map<int, int> pushMap = new Map();
						if(this.regionalProcessors.containsKey(region)) {
							pushMap.addAll(this.regionalProcessors[region].get64BitIDList(alreadySaved));
						}
						
						idMap.addAll(pushMap);
					}
					
					/// Split ALL IDs to grab for this request. ///
					List<List<int>> getIDs = this.process.splitIDsForRequest(idMap);       /// List with ID lists
                    					
					ENV.log("Getting ids: ${JSON.encode(getIDs)}", type: 4);
					
					
					if(getIDs.length > 0) {
					
						List<Future> wait = new List();
						
						for(List<int> requestIDs in getIDs) {
							wait.add(this.getUserData(idMap, requestIDs));
						}
						
						Future.wait(wait).then((List<Map> responses) {
							
							Map<String, Map> store = data;
							
							for(Map response in responses) {
								store.addAll(response);
							}
							
							this.save(ENV.StorageDirectory + "users.json", store).then((_) {
		
								ENV.log("Saved users.json with ${store.length} players.", type: 4);
								
								List<Future> generateBoards = new List();
								Map<String, List> playersProcessedMap = new Map();
								
								/// Add the global processor ///
								generateBoards.add( this.generate(this.process, heroPlayCounts, store) );
								

								/// Calculate players processed and the avg time inbetween processings during the last fetch in ms /// 
								playersProcessedMap["global"] = ["Worldwide", this.process.playersProcessed, this.averageTimeBetweenPlayerProcessing(this.process)]; 
								
								this.process.playersProcessedUpToLastFetch = this.process.playersProcessed;
								
								/// Apply generator to loaded regional processors ///
								for(String region in (ENV.RegionMap).keys.toList()) {

									String name = ENV.RegionIdentifiersSingular[region];
									
									if(this.regionalProcessors.containsKey(region)) {
										Processor proc = this.regionalProcessors[region];
										
										/// Calculate players processed and the avg time inbetween processings during the last fetch in ms /// 
										playersProcessedMap[region] = [name, proc.playersProcessed, this.averageTimeBetweenPlayerProcessing(proc)]; 
										
										proc.playersProcessedUpToLastFetch = proc.playersProcessed;
										
										/// Add the generator future to the future map for wait() ///
										generateBoards.add( this.generate(proc, heroPlayCounts, store) );
									} else {
										playersProcessedMap[region] = [name, -1, 0];
									}
									
								}
	    						
	    						Future.wait(generateBoards).then((_) {
	    							
	    							this.save(ENV.StorageDirectory + "players-processed.json", playersProcessedMap, isJSON: true).then((_) {
		    							ENV.log("Saved boards-latest-primary and boards-latest-mobile.", type: 3);
		    							done();
	    							});
	    						});
							
							});
						});
						
					} else done();
				});
				
			});
		});
	}
	
	
	/**
	 * Organize the boards generation.
	 */
	Future generate(Processor process, heroPlayCounts, store) {
		Map cached = process.getLiveBoards();
        				
		ENV.log("Dispatching generate sequence for ${process.regionalShortcode} @ ${this.recordedMatches.length} matches", type: 2);
		
		List<Future> wait = new List();
		
		for(String board in cached.keys.toList()) {
			if(cached[board]["raw"].length > 0) {
				String first = cached[board]["raw"][0][0];
				ENV.log("First player for $board: $first", type: 4);
				wait.add(this.queries.getAppearancesForPlayerID(first));
			} else {
				wait.add(new Future(() { return {"none": 0}; }));
			}
		}
		
		return Future.wait(wait).then((List<Map> responses) {
			
			Map<String, int> playerTopAppearances = new Map();
			for(dynamic response in responses) {
				playerTopAppearances[ response.keys.first.toString() ] = response.values.first; 
			}
			
			ENV.log("Running generator for ${process.locationIdentifier}", type: 3);
			Generator generator = new Generator(process, this.bans, heroPlayCounts).makeBoards(store, this.recordedMatches, playerTopAppearances);
            						
			for(String player in generator.playersToDiscard) {
				process.discardPlayer(player);
			}
			
			List<Future> wait = [
				this.save(ENV.AppDirectory + "views/boards/${process.regionalShortcode}-primary.blade.php", generator.htmlBasic, isJSON: false), 
				this.save(ENV.AppDirectory + "views/boards/${process.regionalShortcode}-mobile.blade.php", generator.htmlMobile, isJSON: false) 
			];
			
			return wait;
		});
	}
	
	
	
	/**
	 * Run the clean loop.
	 */
	void clean () {
		
		ENV.log("Running clean.", type: 1);
		
		this._pushTimer.cancel();
		this._cleanTimer.cancel();
		
		this.stats.recordClean(this.process.getLiveBoards(), this.process.getAppearances()).then((_) {
			
			ENV.log("Getting board averages.", type: 3);
			
			List<Future> wait = new List();
			Map statMap = new Map();
			for(String board in (ENV.Boards).keys.toList()) {
				
				Future getBoardAverage = this.queries.getBoardAverage(board.toLowerCase());
				wait.add(getBoardAverage);
				
				getBoardAverage.then((List result)  {
					ENV.log("...$board: ${result[0][0].toStringAsFixed(2)}", type: 3);
					statMap[board] = result[0][0].toStringAsFixed(2);
				});  
			}
			
			Future.wait(wait).then((List values) {
				
				ENV.log("Done retrieving board averages, moving to play counts...", type: 4);
				
				this.queries.retrieveHeroPlayCounts().then((heroPlayCounts) {

						
					ENV.log("Sorting hero play counts (${heroPlayCounts.length})...", type: 3);
					
					heroPlayCounts.sort((a, b) => (b[1] - a[1]));
					
					ENV.log("Hero play counts map sorted. (${heroPlayCounts.length})", type: 3);
					
					Map<int, int> heroPlaysMap = new Map();
					
					for(List hero in heroPlayCounts) {
						ENV.log(" | ${hero[0]}: ${hero[1]}");
						heroPlaysMap[hero[0]] = hero[1];		
					}
					
					ENV.log(" | Retrieved play counts (${heroPlaysMap.length}. \n | Generating stats...");
					
					Generator generator = new Generator(this.process).makeStats(statMap, heroPlaysMap);
					
//					ENV.log("STATS: \n ${generator.htmlBasic}");
					
					List<Future> wait = [
						this.save(ENV.AppDirectory + 'views/stats-latest-primary.blade.php', generator.htmlBasic, isJSON: false)
					];
					
					Future.wait(wait).then((_) {
						
						ENV.log("Finished saving stats, re-instantiating Processor() and running start()", type: 4);
						
						this.instantiateProcessors();
						
						this.lastRetrievedMatchCount = 0;
						this.DaemonLifetimeRecordedCount += this.recordedMatches.length;
						this.recordedMatches.clear();
						
						this.util.text("Clean complete @ ${new DateTime.now().toLocal()}. Pushed ${this.DaemonLifetimeRecordedCount} through daemon lifetime.");
						
						queries.retrieveBans().then((bans) {
							this.lastClean = new DateTime.now();
							this.bans = bans;
							this.start();
						});
						
					});
					
					
				});
				
			});
			
			
		});
	}
	
	
	/**
	 * Get the latest match seq num.
	 */
	Future<int> getLatestMatchSeqNum ({wait: true}) {
		
		var completer = new Completer();

		HTTP.get("https://api.steampowered.com/IDOTA2Match_570/GetMatchHistory/v001/?key=${this._key}&matches_requested=1").then((response) {
			if(response.statusCode == 200) {
				completer.complete(JSON.decode(response.body)['result']['matches'][0]['match_seq_num']);
			} else {
				throw new DispatchError("\nFailed to get latest match sequence number. #0001");
			}
		})
		.catchError((error) {
			new Timer(const Duration(seconds: 5), () {
				this.getLatestMatchSeqNum().then((num) {
					completer.complete(num);
				});
			});
		});
		
		return completer.future;
		
	}
	
	
	/**
	 * Request user information from steam API
	 */
	Future getUserData(Map<int, int> idMap, List<int> requestIDs) {
		return HTTP.get("https://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=${this._key}&steamids=${requestIDs.join(",")}")
			.then((response) {
				if(response.statusCode == 200) {
					
					List<Map<String, String>> players = JSON.decode(response.body)["response"]["players"];
					Map<String, Map> thisRequest = new Map();
					
					if(players != null) {
						
						for(Map<String, String> player in players) {
							int player32 = idMap[ int.parse(player["steamid"]) ];
							
							List reverse = player["avatarfull"].split("/").reversed.toList();
							String pic = reverse[1] + "/" + reverse[0];
							
							if(pic == "fe/fef49e7fa7e1997310d705b2a6158ff8dc1cdfeb_full.jpg") 
								pic = null;
							
							thisRequest[player32.toString()] = {
							 	"id": player["steamid"],
							 	"vis": player["communityvisibilitystate"],
							 	"name": player["personaname"].replaceAll(new RegExp(r"<(.*)\b[^>]*>"), ""),
							 	"pic": pic
							};
						}
						
					}
					
					return thisRequest;
				} else throw new DispatchError("Could not get userdata for set ${idMap.toString()}");
			})
			.catchError((Error error) {
				this.requestFailure(error.toString());
				this.util.printError(error);
				ENV.log("Set timer for next request...\n\n\n");
				return new Future.delayed(const Duration(seconds:5), () => this.getUserData(idMap, requestIDs));
			});
	}
	
	
	/**
	 * Read and parse the given file.
	 */
	Future<Map> grab(String file) => new File(file).readAsString().then((String contents) => (contents.length > 0 ? JSON.decode(contents) : new Map()));
	
	
	/**
	 * Write data to file.
	 */
	Future<File> save(String file, dynamic<Map, List, String> data, {isJSON: true}) => new File(file).writeAsString(isJSON == true ? JSON.encode(data) : data);
	
	
	/**
	 * Assess the validity of a match.
	 */
	bool MVF (Map<String, dynamic> match) {
		Map<String, Map<String, int>> teams = { 
			"dire": 
			{ "level": 0, "heroesWithoutAbilities": 0, "abandons":0, "leavers":0, "probablyFakePlayers":0 }, 
			"radiant": 
			{ "level": 0, "heroesWithoutAbilities": 0, "abandons": 0, "leavers":0, "probablyFakePlayers": 0 }
		};
		
		Map ratios = {};
		
		
		/// Loop through players in this match.
		for(var i = 0; i < match['players'].length; i++) {
			String team = "radiant";
			if(i > 4) team = "dire";
			
			Map<String, dynamic> player = match['players'][i];
			
			/// Increment team level.
			teams[team]['level'] += player['level'];
			
			
			/// Check if the player didn't actually level anything
			if(player['level'] > 2 && player.containsKey("ability_upgrades") != true) 
				teams[team]['heroesWithoutAbilities']++;
			
			
			/// Does this player have 128k, 128a, or more than 3 kills per minute? (strong signs of fake game)
			if(player['kills'] >= 128 || player['deaths'] >= 128 || player['assists'] >= 128 || (player['kills'] / (match['duration'] / 60)) > 3) 
				teams[team]['probablyFakePlayers']++;
			
			
			/// Check abandon/leaver status for this player
			if( !([0, 1].contains(player['leaver_status'])) ) 
				teams[team]['abandons']++;
			
			if(player['leaver_status'] == 1) 
				teams[team]['leavers']++;
		}
		
		/// Calculate leavers + abandons for the entire match.
		int totalMatchLeavers = teams["radiant"]["leavers"] + teams["dire"]["leavers"];
		int totalMatchAbandons = teams["radiant"]["abandons"] + teams["dire"]["abandons"];
		
		

		/// Reject a match.
		bool nope(Map teams, int reasonIndex, String reason) {
//			this.queries.discardMatch(match, reason);
			
			/// Pass the rejected match off to the monitor.
			this.monitor.matchRejected(teams, reasonIndex);
			return false;
		}
		
		/// MINIMUM 10 levels / team 
		if( teams['radiant']['level'] > 10 && teams['dire']['level'] > 10) {
		
			/// MAXIMUM of 1 abandon, MAXIMUM of 2 leavers + abandoners
			if( totalMatchAbandons <= 1 && (totalMatchLeavers + totalMatchAbandons) <= 2) {
				
				/// NO players without abilities on each team
				if(teams['radiant']['heroesWithoutAbilities'] <= 1 && teams['dire']['heroesWithoutAbilities'] <= 1) {
					
					/// NO potentially fake players
					if(teams['radiant']['probablyFakePlayers'] == 0 && teams['dire']['probablyFakePlayers'] == 0) {
						
						/// Good to go.
						return true;	
					
					} else return nope(teams, 3, "R:${teams['radiant']['probablyFakePlayers']}, D:${teams['dire']['probablyFakePlayers']}");
					
				} else return nope(teams, 2, "R:${teams['radiant']['heroesWithoutAbilities']}, D:${teams['dire']['heroesWithoutAbilities']}");
				
			} else return nope(teams, 1, "[${totalMatchAbandons.toString()}/${(totalMatchAbandons + totalMatchLeavers).toString()}]");
			
		} else return nope(teams, 0, "Levels < 10");
	}

	

	/**
	 * Receieved a successful request.
	 */
	void requestSuccess() {
		if(this.steamPingAttempts > 0) {
			
			if(this.steamPingAttempts >= 10) {
				Duration down = this.steamDownStartTime.difference(new DateTime.now());
				this.util.text("Steam API back up @ ${new DateTime.now().toLocal()} [${down.toString()}] after ${this.steamPingAttempts} attempts");
				
				this.monitor.hasBeenDown(down.inMinutes);
				
				this.initTimers();
				this.queries.steamStatus(1);
			}
			
			this.steamPingAttempts = 0;
		}
	}
	
	
	/**
	 * Request failed.
	 */
	void requestFailure([String reason="unknown"]) {
		ENV.log("RequestFailure ($reason)", type: 4);
		if(this.steamPingAttempts == 0) 
			this.steamDownStartTime = new DateTime.now();
		
		if(this.steamPingAttempts == 10) {
			ENV.log("Putting the API down...", type: 4);
			this.util.text("Steam API down [reason: $reason] at ${this.steamDownStartTime.toLocal()}");
			
			this.destroyTimers();
			this.queries.steamStatus(0);
		}
		
		this.steamPingAttempts++;
	}



	/**
	 * Return a player map with required information for future processing.
	 */
	Map<String, dynamic> buildPlayerMap(Map player, Map match) {
		return {
			"id": player['account_id'].toString(),
			"match": match["match_id"],
			"loc": match["cluster"],
			"hero": player['hero_id'],
			"items": [player['item_0'], player['item_1'], player['item_2'], player['item_3'], player['item_4'], player['item_5']],
			"kills": player['kills'],
			"deaths": player['deaths'],
			"assists": player['assists'],
			"gold": player['gold'],
			"last_hits": player['last_hits'],
			"denies": player['denies'],
			"gpm": player['gold_per_min'],
			"xpm": player['xp_per_min'],
			"gold_spent": player['gold_spent'],
			"hero_damage": player['hero_damage'],
			"tower_damage": player['tower_damage'],
			"hero_healing": player['hero_healing'],
			"level": player['level'],
			"duration": match["duration"]        
		};
	}
	
	
	/**
	 * Return the average time in MS between this calls to this processor's .player() method
	 */
	int averageTimeBetweenPlayerProcessing(Processor proc) => ((1 / ((proc.playersProcessed - proc.playersProcessedUpToLastFetch) / 1200)) * 1000).toInt();

}