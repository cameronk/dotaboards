part of process;

class Monitor {
	
	
	int matchesStashed;
	double matchProcessingDelay;
	List<double> averageMatchProcessingDelays = new List();
	
	int downtimeSinceLastPush; /// in minutes
	
	List rejectedMatchCounts;
	
	List pushList = new List();
	
	/**
	 * Monitor statistics about the daemon over its lifetime.
	 */
	Monitor() {
		ENV.log("Instantiated monitor.", type: 4);
		
		this.reset();
	}
	
	
	/**
	 * Monitor this particular match.
	 * @return void
	 */
	void match(Map match) {
		
		matchesStashed++;

	
		/// 		matchProcessingDelay			///
		/// 										///
		/// First, let's calculate the diff in time ///
		/// between when this match was completed,  ///
		/// and when it was actually processed.		///
		/// 										///
		
		DateTime completedAtMillisecondsSinceEpoch = new DateTime.fromMillisecondsSinceEpoch((match["start_time"] * 1000) + (match["duration"] * 1000));
		double differenceFromNow = (new DateTime.now().difference(completedAtMillisecondsSinceEpoch).inSeconds / 60).abs();
		
		this.matchProcessingDelay += differenceFromNow;
		
	}
	
	
	/**
	 * A match has been rejected.
	 */
	void matchRejected(Map teams, int reasonIndex) {
		this.rejectedMatchCounts[reasonIndex]++;
	}
	
	
	/**
	 * Increment downtime since last push.
	 */
	void hasBeenDown(int minutes) {
		this.downtimeSinceLastPush += minutes;
	}
	
	
	/**
	 * Output the data we've collected so far.
	 */
	void push() {
		
		ENV.log("[Monitor] running push sequence @ loop ${this.averageMatchProcessingDelays.length}", type: 4);
		
		DateTime now = new DateTime.now();
		
		/// Build a map of new data to associate with this push loop. ///
		Map newDataThisPush = {
		    "recordedAt": now.toLocal().toString(),
			"delay": this.matchProcessingDelay / this.matchesStashed,
			"downtime": this.downtimeSinceLastPush,
			"rejectedMatchCounts": this.rejectedMatchCounts
		};
		
		
		/// Add the new data to our list of pushes ///
		this.pushList.add(newDataThisPush);
		
		/// Store in a file on the server ///
		this.save(ENV.StorageDirectory + "monitors/monitor-${now.year}-${now.month}-${now.day}.json", this.pushList, isJSON: true);
		
		/// Reset push-based variables to 0 ///
		this.reset();
	}

	
	/**
	 * Write data to file.
	 */
	Future<File> save(String f, dynamic<Map, List, String> data, {isJSON: true}) {
		
		File file = new File(f);
		
		if(file.exists() == false) {
			file.create().then((File file) {
				file.writeAsString(isJSON == true ? JSON.encode(data) : data);
			});
		} return file.writeAsString(isJSON == true ? JSON.encode(data) : data);
	
	}
	
	/**
	 * Reset push-based variables to their default values.
	 */
	void reset() {
		
		this.matchesStashed = 0;
		this.matchProcessingDelay = 0.00;
		this.downtimeSinceLastPush = 0;
		this.rejectedMatchCounts = [0, 0, 0, 0];
		
	}
	
}