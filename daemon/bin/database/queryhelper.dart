part of pool;

class QueryHelper {
	
	ConnectionPool pool;
	final Duration queryTimeout = const Duration(seconds: 120);
	
	QueryHelper(ConnectionPool pool) {
		this.pool = pool;	
	}
	
	dynamic _attempt(dynamic<Future<Results>, Future<List<Results>>> query) {
		try {
			query.timeout(this.queryTimeout, onTimeout: () { 
				ENV.log("ERROR: Query timed out.", type: 4);
				throw new QueryError("Query timed out.");
			}).catchError((e) {
				this._attempt(query);
				ENV.log(e.toString(), type: 4);
				ENV.log("ERROR: Caught error ${e.toString()} in query.", type: 3);
			});
		} catch(e) {
			ENV.log("Query catchError thrown to wrapping try/catch", type: 3);
			ENV.log(e);
		} finally {
			return query;
		}
	}
	
	
	/**
	 * Truncates the matches table.
	 */
	Future<Results> truncateMatches() {
		ENV.log("QueryHelper::truncateMatches()", type: 3);
		try {
			return this._attempt(this.pool.query("TRUNCATE `matches`"));
		} catch(e) {
			throw new QueryError("Failed to truncate matches: " + e.toString());
		}
	}
	
	
	/**
	 * Retreive list of bans from table.
	 */
	Future<List<int>> retrieveBans() {
		ENV.log("QueryHelper::retrieveBans()", type: 3);
		
//		{
//        				List ids = new List();
//        				return results.forEach((row) {
//        					ids.add(row.id);
//        				}).then((_) {
//        					return ids;
//        				});
//        				
//        			}
		
		try {
			return this._attempt(this.pool.query("SELECT `id` FROM `player-bans`")).then(
				(results) => results.toList().then(
					(list) => list.map((row) => row[0]).toList()
				) 
			);
		} catch(e) {
			throw new QueryError("Failed to retrieve bans: " + e.toString());
		}
	}
	
	
	/**
	 * Push a match to the matches table.
	 */
	Future pushMatch(Map match) {
//		ENV.log("QueryHelper::pushMatch()");
		try {
			return pool.prepare("INSERT INTO `matches` (id, seqnum, cluster, gamemode, radiant_win, completed_at) VALUES (?, ?, ?, ?, ?, ?)").then((query) {
				return this._attempt(query.execute(match.values.toList()));
			});
		} catch(e) {
			throw new QueryError("Failed to push match: " + e.toString());
		}
	}
	
	
	
	/**
	 * Return hero play counts.
	 */
	Future<List> retrieveHeroPlayCounts({sort:true}) {
		ENV.log("QueryHelper::retrieveHeroPlayCounts()", type: 3);
		try {
			return this._attempt(this.pool.query("SELECT * FROM `heroes` ORDER BY count DESC")).then((Results results) {
	
				//if(sort == true) {
					List heroPlayCounts = new List();
					
					return results.forEach((row) {
						heroPlayCounts.add([row.id, row.count]);
					}).then((_) => heroPlayCounts);
				//} else return results;
				
			});
		} catch(e) {
			throw new QueryError("Failed to retrieve hero play counts: " + e.toString());
		}
	}
	
	
	/**
	 * Add match to discarded table.
	 */
	Future discardMatch(Map match, String reason) {
		//ENV.log("QueryHelper::discardMatch()");
		try {
			return pool.prepare("INSERT INTO `discarded-matches` (id, seq, reason) VALUES(?, ?, ?)").then((query) {
				return this._attempt(query.execute([match['match_id'], match['match_seq_num'], reason]));
			});
		} catch(e) {
			throw new QueryError("Failed to discard match: " + e.toString());
		}
	}
	
	

	
	/// ----------------------------------------------------------------------------------------- ///
	
	
	
	
	/**
	 * Update the current match count for today.
	 */
	Future<Results> updateCurrentMatchCount(int currentRecordedMatchCount) {
		ENV.log("QueryHelper::updateCurrentMatchCount($currentRecordedMatchCount)", type: 3);
		try {
			return pool.prepare("UPDATE `site` SET `current_match_count`=? WHERE `id`='0'").then((query) {
				return this._attempt(query.execute( [ currentRecordedMatchCount ]  ));
			});
		} catch(e) {
			throw new QueryError("Failed to update current match count: " + e.toString());
		}
	}
	
	
	
	/**
	 * Update the all-time match count.
	 */
	Future updateTotalMatchCount(int currentRecordedMatchCount, int lastRetrievedMatchCount) {
		ENV.log("QueryHelper::updateTotalMatchCount($currentRecordedMatchCount, $lastRetrievedMatchCount)", type: 3);
		try {
			return pool.prepare("UPDATE `site` SET `total_match_count`=total_match_count + ? WHERE `id`='0'").then((query) {
				return this._attempt(query.execute( [ currentRecordedMatchCount - lastRetrievedMatchCount ] ));
			});
		} catch(e) {
			throw new QueryError("Failed to update current match count: " + e.toString());
		}
	}
	
	
	
	/**
	 * Update player stat counts
	 */
	Future updatePlayerStatCounts(Map<String, Map> playerStats) {
		ENV.log("QueryHelper::updatePlayerStatCounts(playerStats: ${playerStats.toString()})", type: 3);
		try {
			
			List statsList = [
				playerStats["current"]["kills"], 
				playerStats["current"]["deaths"], 
				playerStats["current"]["assists"], 
				playerStats["current"]["duration"], 
				playerStats["total"]["duration"], 
				playerStats["total"]["kills"], 
				playerStats["total"]["deaths"], 
				playerStats["total"]["assists"]
			];
			
			ENV.log("Using statslist: ${statsList.toString()}");
			
			String query = "UPDATE `site` SET `current_kills`=?, `current_deaths`=?, `current_assists`=?, `current_duration`=?, `total_duration`=total_duration + ?, `total_kills`=total_kills + ?, `total_deaths`=total_deaths + ?, `total_assists`=total_assists + ? WHERE `id`='0'";
			return pool.prepare(query).then((query) {
				return this._attempt(query.execute( statsList ));
			});
		} catch(e) {
			throw new QueryError("Failed to update current match count: " + e.toString());
		}	
	}
	

	/// ----------------------------------------------------------------------------------------- ///
	
	/**
	 * Insert stats row with today's average statistics.
	 */
	Future insertNewStatsRow(Map stats) {
		ENV.log("QueryHelper::insertNewStatsRow()", type: 3);
		try {
			String set = "";
			for(String stat in stats.keys.toList()) {
				set += "`$stat`=${stats[stat]}, ";
			}
			
			//ENV.log("INSERT INTO `stats` SET ${set.substring(0, (set.length - 2))}");
			return this._attempt(pool.query("INSERT INTO `stats` SET ${set.substring(0, (set.length - 2))}"));
		} catch(e) {
			throw new QueryError("Failed to insert new stats row " + e.toString());
		}	
	}
	
	
	
	/**
	 * Increment the number of days online by 1.
	 */
	Future updateDaysOnline() {
		ENV.log("QueryHelper::updateDaysOnline()", type: 3);
		try {
			return pool.prepare("UPDATE `site` SET `days_online`=days_online + ? WHERE `id`=0").then((query) {
				return this._attempt(query.execute( [ 1 ] ));
			});
		} catch(e) {
			throw new QueryError("Failed to update days online.  " + e.toString());
		}	
	}
	
	
	
	/**
	 * Update player appearances table.
	 */
	Future updatePlayerAppearances( Map<String, int> appearances ) {
		ENV.log("QueryHelper::updatePlayerAppearances()", type: 3);
		
		List converted = new List();
		for(String playerID in appearances.keys.toList()) {
			converted.add( [ playerID, appearances[playerID] ] );
		}
		
		try {
			return pool.prepare("INSERT INTO `appearances` (id, count) VALUES (?, ?) ON DUPLICATE KEY UPDATE id = VALUES(id), count = count + VALUES(count)").then((query) {
				return this._attempt( 
					query.executeMulti( converted )
				);
			});
		} catch(e) {
			throw new QueryError("Failed to update player appearances.  " + e.toString());
		}	
	}
	
	
	/**
	 * Get player appearances for specific ID.
	 */
	Future getAppearancesForPlayerID(String id, String boardName) {
		ENV.log("QueryHelper::getAppearancesForPlayerID($id)", type: 3);
		try {
			return this._attempt(this.pool.query("SELECT count FROM `appearances` WHERE id = ${id} LIMIT 1"))
				.then((Results results) {
					ENV.log(" | QueryHelper: Returned appearances for $boardName-$id");
					Map appearance = new Map();
					appearance[id] = 1;
					return results.forEach((row) {
						ENV.log("forEach($id): ${row.count}");
						appearance[id] += row.count;
					}).then((_) => appearance);
				});
		} catch(e) {
			throw new QueryError("Failed to retrieve apperances for $id " + e.toString());
		}
	}
	
	
	/**
	 * Update hero play counts.
	 */
	Future updateHeroPlayCounts(Map<int, int> heroes) {
		ENV.log("QueryHelper::updateHeroPlayCounts()", type: 3);
		
		List converted = new List();
		for(int heroID in heroes.keys.toList()) {
			converted.add( [ heroes[heroID], heroID ] );
		}
		
		try {
			return pool.prepare("UPDATE `heroes` SET count = count + ? WHERE `id` = ?").then((query) {
				return this._attempt( 
					query.executeMulti( converted )		
				);
			});
		} catch(e) {
			throw new QueryError("Failed to update hero play counts.  " + e.toString());
		}	
		
	}
	
	
	
	/**
	 * Get averages of this stats row.
	 */
	Future getBoardAverage(String board) {
		ENV.log(" | QueryHelper::getBoardAverage($board)", type: 3);
		try {
			return this._attempt(pool.query("SELECT AVG(avg_${board}) AS ${board} FROM stats")).then((result) => result.toList());
		} catch(e) {
			throw new QueryError(" | Failed to get board average for ${board}.  " + e.toString());
		}
	}
	
	

	/// ----------------------------------------------------------------------------------------- ///
	
	/**
	 * Update steam status to specified value
	 */
	Future steamStatus(int val) {
		ENV.log("QueryHelper::steamStatus($val)", type: 3);
		try {
			return this._attempt(pool.query("UPDATE `site` SET `steam_online` = '${val.toString()}', `steam_down_at` = CURRENT_TIMESTAMP()"));
		} catch(e) {
			throw new QueryError("Failed to get update steam status -> ${val.toString()}: " + e.toString());
		}
	}
	
}