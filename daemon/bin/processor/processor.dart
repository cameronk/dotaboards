library process;

import "dart:convert";
import "dart:async";
import "dart:io";
import "dart:math" as Math;

import "../util/util.dart";
import "../database/pool.dart";

part "generator.dart";
part "statistics.dart";
part "monitor.dart";

class Processor {
	
	/**
	 * Heirarchy:
	 * 
	 * 
	 * Boards {
	 * 		|Board Name|: {
	 * 			raw: [ [|Player ID|, |Value|], 			... ],
	 * 			det: { |Player ID|: { |Player Data| }, 	... }
	 * 		}
	 * }
	 *  
	 */
	Map<
		/// Board name ///
		String, 
		Map<
			/// Raw / detailed ///
			String, 
			dynamic<
				/// Raw board ///
				List<
					/// Individual player ///
					List<
						dynamic<
							String, /// player ID
							int /// board value
						>
					>
				>, 
				
				/// Detailed board ///
				Map<
					String, /// player ID 
					Map  /// player-specific info
				>
			>
		>
	> 									Boards;
	Map<String, Map<String, int>>		CumStats;
	
	int									playersProcessedUpToLastFetch = 0;
	int 								playersProcessed = 0;
	
	Map<String, int> 					Appearances;
//	Set<String>							_RecentlyRetrievedPlayers;
	
	String regionalShortcode;
	String locationIdentifier;
	
	
	/**
	 * Initiate a new processor object to handle incoming data.
	 * 
	 * NOTICE:
	 * All values must be stored as integers for proper sorting, and processed into actual double values at the time of output.
	 */
	Processor(String regionalShortcode, String locationIdentifier) {
		
		ENV.log("Instantiated processor ${this.hashCode} with shortcode: ${regionalShortcode}, ident: ${locationIdentifier}", type: 3);
		
		this.Boards =  {
			// Kill-death-assist, gold per min, xp per min, creep score //
			"KDA": {
				"raw": [],
				"det": {}
			},
			"GPM": {
				"raw": [],
				"det": {}
			},
			"XPM": {
				"raw": [],
				"det": {}
			},
			"CS": {
				"raw": [],
				"det": {}
			},
			
			// hero damage, tower damage, credit to team //
			"HD": {
				"raw": [],
				"det": {}
			},
			"TD": {
				"raw": [],
				"det": {}
			},
			"C2T": {
				"raw": [],
				"det": {}
			}
		};
		
		this.CumStats 		= new Map<String, Map<String, int>>.from(ENV.CumulativeStatistics);
		
		this.Appearances				= new Map<String, int>();
//		this._RecentlyRetrievedPlayers 	= new Set<String>();
		
		
		this.regionalShortcode 			= regionalShortcode;
		this.locationIdentifier			= locationIdentifier;
		
	}
	
	Future setup() {
		
		return ENV.state.RestoreProcessor(this);
		
	}
	
	
	

	
	/// ----------------------------------------------------------------------------------------- ///

	/**
	 * Dispatch a player map to all proecssor functions.
	 */
	void player(Map player) {
		
		this.playersProcessed++;
		
		this.KDA(player);
		this.GPM(player);
		this.XPM(player);
		this.CS(player);
		this.HD(player);
		this.TD(player);
		this.C2T(player);
	}
	
	
	/**
	 * Process player KDA.
	 */
	void KDA(Map player) {
		
		double base = this.getBase("KDA", 25);
		double kda  = double.parse( ((player['kills'] + player['assists']) / (player['deaths'] > 0 ? player['deaths'] : 1)).toStringAsFixed(2) );
		
		if(kda > base)
			this.updateBoard("KDA", player, kda);
	}
	
	
	/**
	 * Process player GPM.
	 */
	void GPM(Map player) {
		
		double base = this.getBase("GPM", 500);
		
		if(player['gpm'] > base) 
			this.updateBoard("GPM", player, player['gpm'].toDouble());
		
	}
	
	
	/**
	 * Process player XPM.
	 */
	void XPM(Map player) {
		
		double base = this.getBase("XPM", 500);
		
		if(player['xpm'] > base) 
			this.updateBoard("XPM", player, player['xpm'].toDouble());
		
	}
	

	/**
	 * Process player CS.
	 */
	void CS(Map player) {
		
		double base = this.getBase("CS", 8);
		double cs = double.parse(( (player['last_hits'] + player['denies']) / ((player['duration'] / 60)) ).toStringAsFixed(2));
		
		if(cs > base) 
			this.updateBoard("CS", player, cs);
		
	}
	
	
	/**
	 * Process player HD.
	 */
	void HD(Map player) {

		double base = this.getBase("HD", 30000);
		
		if(player['hero_damage'] > base) 
			this.updateBoard("HD", player, player['hero_damage'].toDouble());
	}
	

	/**
	 * Process playerTD.
	 */
	void TD(Map player) {

		double base = this.getBase("TD", 8000);
		
		if(player['tower_damage'] > base) 
			this.updateBoard("TD", player, player['tower_damage'].toDouble());
	}
	

	/**
	 * Process player C2T
	 */
	void C2T(Map player) {

		double base = this.getBase("C2T", 1);
		double contribution = player['tower_damage'] + player['hero_damage'] + Math.pow(player['hero_healing'], 1.875);
		double c2t  = double.parse( Math.sqrt(contribution / Math.pow(player['duration'], 2)).toStringAsFixed(2) );
		
		if(c2t > base) 
			this.updateBoard("C2T", player, c2t);
	}
	
	
	
	
	/// ----------------------------------------------------------------------------------------- ///
	
	
	
	
	/**
	 * Update the specified board with player information and value.
	 */
	void updateBoard(String board, Map player, double val) {
		
		ENV.log("         --> $board", type: 3);
		//ENV.log("Before: " + JSON.encode(this.Boards[board]['raw']));
		
		int value = (val * ENV.PrecisionModifierMap[board]).toInt();
		
		this.playerAppeared(player['id']);
		this.updateCumulativeStatistics(player);
		
		/// Update raw board. ///
		if( this.playerExistsOnBoard(board, player["id"]) ) {
			
			/// Overwrite player's previous entry if lower than new one. ///
			int currentRawBoardIndex = this.findRawIndexByID(board, player["id"]);
			ENV.log("Duplicate entry: Found player ${player['id']} on ${this.regionalShortcode}-${board} at index ${currentRawBoardIndex.toString()}", type: 4);
			
			if(value > this.Boards[board]["raw"][currentRawBoardIndex][1]) {
				
				this.Boards[board]["raw"][currentRawBoardIndex][1] = value;
				this.Boards[board]["det"][player['id']]			= player;
				this.sortBoard(board); /// Re-sort after modifying a value to ensure it's correctly placed.
				
			}
			
		} else {
			
			/// Boards are full, remove lowest player ///
			if( this.Boards[board]["raw"].length >= 100 ) {
				
				this.sortBoard(board); /// Sort to ensure we remove the correct (last-place) value.

				this.Boards[board]["det"].remove(this.Boards[board]["raw"].last[0]);
				this.Boards[board]["raw"].removeLast();
				
			}
			this.Boards[board]["raw"].add([ player['id'], value ]);
			this.Boards[board]["det"][player["id"]] = player;
		}
		

		//ENV.log("After  :" +JSON.encode(this.Boards[board]['raw']));
		//ENV.log("\n\n");
	}
	
	
	/**
	 * Save boards to JSON file.
	 */
//	Future<File> saveBoards() {
//		
//		this.sortBoards(); /// Run a complete sort before output.
//		
//		Future<File> doSave(File file) {
//			var json = JSON.encode(this.Boards);
//			
//			try { 
//				return file.writeAsString(json);
//			} catch(e) {
//				ENV.log("Found error at file save point", 4);
//			}
//		};
//		
//		var file = new File(ENV.StorageDirectory + "boards.json");
//		return file.exists().then((x) {
//			if(x == true) {
//				return file.create().then((file) => doSave(file));
//			} else {
//				ENV.log("Returned file exists false", 4);
//				return doSave(file);
//			}
//		});
//	}
	
	
	/**
	 * Return the lowest value on the specified board.
	 * 
	 * If no lowest value exists, return a default value.
	 */
	double getBase(String board, int def) {
		this.sortBoard(board); /// Sort to ensure we're returning the true 'last' value.
		return (this.Boards[board]["raw"].length >= 100) ? (this.Boards[board]["raw"].last[1].toDouble() / ENV.PrecisionModifierMap[board]) : def.toDouble();
	}
	
	
	/** 
	 * Check if a player is listed in the specified board.
	 */
	bool playerExistsOnBoard(String board, String id) => this.Boards[board]["det"].containsKey(id);
	
	
	/** 
	 * Find a player's current index in the specified raw board.
	 */
	dynamic findRawIndexByID(String board, String id) {
		var element = this.Boards[board]["raw"].firstWhere((List element) => element.contains(id), orElse: () => null);
		if(element != null) 
			return this.Boards[board]["raw"].indexOf(element);
		else return null;
	}
	

	/**
	 * Discard a player from the boards.
	 */
	void discardPlayer(String id) {
		ENV.log("Discarding $id from ${this.regionalShortcode}", type: 3);
		for(String board in this.Boards.keys.toList()) {
			
			this.Boards[board]["raw"].removeWhere((List element) => element.contains(id));
			this.Boards[board]["det"].remove(id);
			
		}
	}
	
	
	/**
	 * Clear the recently retrieved players set.
	 */
//	void clearRecentlyRetrievedPlayers() => this._RecentlyRetrievedPlayers.clear(); 
	
	
	/**
	 * Sort the boards.
	 */
	void sortBoard(String board) => this.Boards[board]["raw"].sort((List a, List b) =>  (b[1] - a[1]) );
	
	
	/**
	 * Sort ALL boards.
	 */
	void sortBoards() => this.Boards.keys.forEach((key) => this.sortBoard(key));
	
	
	

	/// ----------------------------------------------------------------------------------------- ///
	
	
	
	/**
	 * Update the appearances object to include this player.
	 */
	void playerAppeared(String id) {
		
//		this._RecentlyRetrievedPlayers.add(id);
		
		if(this.Appearances.containsKey(id)) {
			this.Appearances[id] = this.Appearances[id];
		} else {
			this.Appearances[id] = 1;
		}
	}
	
	
	
	
	
	/**
	 * Update cumulative statistics map.
	 */
	void updateCumulativeStatistics(Map player) {
		
		//ENV.log(" | Pushing ${player['id']} to cumstats (+${player['kills']})");
		
		this.CumStats["current"]["kills"] += player["kills"];
		this.CumStats["current"]["deaths"] += player["deaths"];
		this.CumStats["current"]["assists"] += player["assists"];
		this.CumStats["current"]["duration"] += player["duration"];

		this.CumStats["total"]["kills"] += player["kills"];
		this.CumStats["total"]["deaths"] += player["deaths"];
		this.CumStats["total"]["assists"] += player["assists"];
		this.CumStats["total"]["duration"] += player["duration"];
	}
	
	
	/**
	 * Get cumulative statistics map.
	 */
	Map getCumulativeStatistics() => this.CumStats;
	
	
	/**
	 * Clear the 'total' section of cumulative statistics so that
	 * our addition is accurate next time around
	 */
	void resetCumulativeStatistics() {
		for(String stat in this.CumStats["total"].keys.toList()) {
			this.CumStats["total"][stat] = 0;
		}
	}
	
	
	/**
	 * Get the live boards.
	 */
	Map getLiveBoards() => this.Boards;
	
	
	/** 
	 * Get appearances.
	 */
	Map<String, int> getAppearances() {
		return this.Appearances;
	}

	
	
	/// ----------------------------------------------------------------------------------------- ///
	
	
	
	/**
	 * Split a map of 64bit:32bit IDs into a list<list[100]> 
	 * for use in requests.
	 */
	List<List<int>> splitIDsForRequest(Map<int, int> idMap) {
		List<int> id64List  = idMap.keys.toList();
		List<List<int>> getIDs = new List();
		
		if(idMap.length > 0) {
			
			/// 457 ids = 5 requests ///
			/// 1: 0-99
			/// 2: 100-199
			/// 3: 200-299
			/// 4: 300-399
			/// 5: 400-457
			
			int requiredRequestCount = (id64List.length / 100).ceil();
			for(int i = 1; i <= requiredRequestCount; i++) {
				ENV.log("Delegating request ${i}...", type: 4);
				
				int stop;
				int start = (i - 1) * 100;
				
				if(i == requiredRequestCount) 
					stop = id64List.length;
				else 
					stop = (i * 100); 
			
				getIDs.add( id64List.getRange(start, stop).toList() );
			}
		}
		
		return getIDs;
	}
	
	
	/** 
	 * Return a map of 64-bit:32-bit IDs.
	 */
	Map<int, int> get64BitIDList(List<String> exclude) {
		Map<int, int> ids = new Map();
		int dupes = 0;
		for(String board in this.Boards.keys) {
			
			ENV.log("Getting 64-bit id hashmap on ${this.regionalShortcode}-${board}", type: 4);
			List<List<dynamic<String, int>>> rawBoard = this.Boards[board]["raw"];
			
			for(int i = 0; i < rawBoard.length; i++) {
				
				int id32 = int.parse(rawBoard[i][0]);
				if(ids.containsValue(id32)) dupes++;
				
				/// Check if we've already stored this users' information, or
				/// if the id64:id32 pair has already been stored
				/// (probably from a previous board)
				if(!exclude.contains(id32.toString()) && !ids.containsValue(id32)) {
					int id64 = ENV.util.to64(id32);
					ids[id64] = id32;
				}
			}
			
			
		}
		
		ENV.log("...Returning ${ids.length} IDs", type: 4);
		return ids;
	}
	
}