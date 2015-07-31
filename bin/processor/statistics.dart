part of process;


class Statistics {

	
	QueryHelper queries;
	File statsLogFile;
	
	Statistics(QueryHelper queries) {
		this.queries = queries;
		statsLogFile = new File(ENV.StorageDirectory + "statistics.txt");
	}
	
	
	/**
	 * Record statistics relevant to each push loop.
	 * 
	 * currentRecordedMatches:   SET of all matches recorded with this dispatcher
	 * lastRetrievedMatchCount:  How many matches were recorded at the end of the last push loop
	 * playerStats:              Equivalent of processor's _CumulativeStatistics, records player stats
	 */
	Future recordPush(Set currentRecordedMatches, int lastRetrievedMatchCount, Map<String, Map> playerStats) {
		print("Recording stats for PUSH.");
		
		this.statsLogFile.writeAsString("${new DateTime.now().toLocal()}: pushing currentRecordedMatches=${currentRecordedMatches.length}, lastRetrievedMatchCount=${lastRetrievedMatchCount}\n\n playerStats:\n${playerStats}", mode: APPEND);
		
		List<Future> wait = [
			queries.updateCurrentMatchCount( currentRecordedMatches.length ),
			queries.updateTotalMatchCount( currentRecordedMatches.length, lastRetrievedMatchCount ),
			queries.updatePlayerStatCounts( playerStats )
		];
		
		return Future.wait(wait);
	}

	
	
	
	Future recordClean( Map cachedBoards, Map<String, int> appearances) {
		print(" | Recording stats for CLEAN.");
		
		Map<String, String> stats 	= new Map();
		Map<int, int> heroes 		= new Map();
		
		for(String board in cachedBoards.keys.toList()) {
			
			double total = 0.00;
			
			for(List player in cachedBoards[board]["raw"]) {
				total += (player[1] / ENV.PrecisionModifierMap[board]);
			}
			
			for(String player in cachedBoards[board]["det"].keys.toList()) {
				int hero = cachedBoards[board]["det"][player]['hero'];
				if(heroes.containsKey(hero))
					heroes[hero] += 1;
				else
					heroes[hero]  = 1;
			}
			
			String avg = (total / cachedBoards[board]["raw"].length).toStringAsFixed(5);
			
			print(" | Average for $board: $avg (total: $total)");
			
			stats["avg_${board.toLowerCase()}"] = avg;
			
		}
		
		
		List<Future> wait = [
			queries.insertNewStatsRow(stats),
			queries.updateDaysOnline(),
			queries.updatePlayerAppearances(appearances),
			queries.updateHeroPlayCounts(heroes)
		];
		
		return Future.wait(wait);
		
	}
	
}