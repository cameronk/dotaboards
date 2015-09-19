part of util;

class State {

	/**
	 * State - Data structures
	 * 
	 * ===================================================
	 * 
	 * 	.state.json 
	 * 	{
	 * 		"date" : [date of last writing to this file]
	 * 		"startingMatch": [last seq number polled]
	 * 	}
	 * 
	 * 
	 * 	.[region].state.json
	 * 	{
	 * 		"date" : [date of last writing to this file]
	 * 	 	"boards": [boards object]
	 * 	 	"cumstats": [cumulative statistics object]
	 * 	}
	 * 
	 * ===================================================
	 * 
	 */


	List<String> reviveDataKeys = ["date", "startingMatch"];
	List<String> processorDataKeys = ["date", "boards", "cumstats", "appearances"];
	int startingMatch = null;

	
	/**
	 * Instantiate a new State object
	 * 
	 * @return void
	 */
	State() {

	}


	/**
	 * Revive the daemon
	 * 
	 * @return Future
	 */
	Future Revive() {

		ENV.log("Attempting to revive previous Dotaboards daemon.");
		return ENV.grab(ENV.StorageDirectory + "state/daemon.json").then((Map<String, dynamic> stateData) {

			/// If data was found in this file
			if (stateData.length > 0) {

				if (this.Validate(this.reviveDataKeys, stateData)) {
					ENV.log("Reviving daemon from ${stateData['date']}");

					/// Set up data from previous state.
					this.startingMatch = stateData['startingMatch'];

				} else {
					ENV.log("Found revive data for daemon, but it is invalid.");
				}

			} else {
				ENV.log("Revive found no state data. Starting fresh.");
			}

		});

	}

	/**
	 * Store dispatcher data for later 
	 * reviving the daemon
	 * 
	 * @return Future
	 */
	Future Store(dynamic<Dispatcher, Processor> object) {

		if(object is Dispatcher) {
			
			ENV.log("Storing state data for dispatcher.", type:3);
			Map data = {
    			"date": new DateTime.now().toLocal().toString(),
    			"startingMatch": object.lastMatchSequenceNum
    		};

    		return ENV.save(ENV.StorageDirectory + "state/daemon.json", data, isJSON: true);
	
		} else {
			Map data = {
		    	"date": new DateTime.now().toLocal().toString(),
				"boards": object.Boards,
				"cumstats": object.CumStats,
				"appearances": object.Appearances,
			};
    		
			return ENV.save(ENV.StorageDirectory + "state/${object.regionalShortcode}.state.json", data, isJSON: true);
	
		}

	}


	/**
	 * Search for past processor data.
	 * 
	 * @return Future
	 */
	Future RestoreProcessor(Processor processor) {

		ENV.log("Attempting to revive processor ${processor.regionalShortcode}.");
		return ENV.grab(ENV.StorageDirectory + "state/${processor.regionalShortcode}.state.json").then((Map<String, dynamic> stateData) {

			/// If data was found in this file
			if (stateData.length > 0) {
				if (this.Validate(this.processorDataKeys, stateData)) {
					ENV.log("Reviving processor ${processor.regionalShortcode} from ${stateData['date']}");

					/// Set up data from previous state.
					processor.Boards 	= stateData['boards'];
					processor.CumStats 	= stateData['cumstats']; 
					processor.Appearances = stateData['appearances'];

				} else {
					ENV.log("Found revive data for processor ${processor.regionalShortcode}, but it is invalid.");
				}
			} else {
				ENV.log("No state data found for processor ${processor.regionalShortcode}. ");
			}

		});

	}


	/**
	 * Is the revive data valid?
	 * 
	 * @return bool
	 */
	bool Validate(List keys, Map<String, dynamic> stateData) {

		bool valid = true;

		keys.forEach((String key) {
			if (!stateData.containsKey(key)) {
				valid = false;
			}
		});

		return valid;
	}

}
