part of process;

class Monitor {
	
	
	/// Request-related
	int rawMatchCount;
	int fetchRequestResponses;
	int totalFetchResponseTime;
	int totalRequestsSent = 0;
	
	/// Match-related
	int filteredMatchCount;
	double matchProcessingDelay;
	List<double> averageMatchProcessingDelays = new List();
	
	/// Downtime calculations
	int downtimeSinceLastPush; /// in minutes
	
	/// How many matches have we rejected?
	List rejectedMatchCounts;
	
	/// This is the list we'll write to the file.
	List pushList = new List();
	
	/**
	 * Monitor statistics about the daemon over its lifetime.
	 */
	Monitor() {
		ENV.log("Instantiated monitor.", type: 4);
		
		this.reset();
	}
	
	void apiRequest() {
		this.totalRequestsSent++;
	}
	
	/**
	 * Store data related to this fetch request.
	 * @return void
	 */
	void fetchRequest(List<Map> matches, int responseTimeInMs) {
		
		this.fetchRequestResponses++;
		
		///		averageMatchesPerRequest		///
		/// Calculate the average number of 	///
		/// matches we fetch in a given request ///
		/// (useful for monitoring peak times) 	///
		
		this.rawMatchCount += matches.length;
		this.totalFetchResponseTime += responseTimeInMs;
		
	}
	
	
	/**
	 * Monitor this particular match.
	 * @return void
	 */
	void match(Map match) {
		
		filteredMatchCount++;

	
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
	void push(Processor mainProcess, Map<String, Processor> regionalProcessors) {
		
		ENV.log("[Monitor] running push sequence @ loop ${this.averageMatchProcessingDelays.length}", type: 4);
		
		DateTime now = new DateTime.now();
		
		/// Build a map of new data to associate with this push loop. ///
		Map newDataThisPush = {
		                       
		    /// Proprietary
		    "recordedAt": now.toLocal().toString(),
		    
		    /// Request count for this loop
		    "fetchRequestResponses": this.fetchRequestResponses,
		    
		    /// Total request count for this loop
		    "totalRequests": this.totalRequestsSent,
		    
		    /// Average matches per request
		    "averageMatchesPerRequest": this.rawMatchCount / this.fetchRequestResponses,
		    
		    /// Average fetch response time
		    "averageFetchResponseTime": this.totalFetchResponseTime / this.fetchRequestResponses,
		    
		    /// Average difference between match ending and match processing
			"delay": this.matchProcessingDelay / this.filteredMatchCount,
			
			/// Total daemon downtime
			"downtime": this.downtimeSinceLastPush,
			
			/// How many matches were rejected by the MVF in the past push loop
			"rejectedMatchCounts": this.rejectedMatchCounts,
			
			/// Processor
			"processors": {
				"global": {
					"playersProcessed": mainProcess.playersProcessed - mainProcess.playersProcessedUpToLastFetch
				}
			}
			
		};
		
		regionalProcessors.forEach((String name, Processor processor) {
			newDataThisPush["processors"][name] = new Map();
			newDataThisPush["processors"][name]["playersProcessed"] = processor.playersProcessed - processor.playersProcessedUpToLastFetch;
		});
		
		/// Add the new data to our list of pushes ///
		this.pushList.add(newDataThisPush);
		
		/// Store in a file on the server ///
		this.save(ENV.StorageDirectory + "monitors/monitor-latest.json", this.pushList, isJSON: true);
		
		/// Reset push-based variables to 0 ///
		this.reset();
	}

	
	/**
	 * Write data to file.
	 */
	Future<File> save(String f, dynamic<Map, List, String> data, {isJSON: true}) {
		
		File file = new File(f);
		
		if(file.exists() == false) {
			return file.create().then((File file) {
				return file.writeAsString(isJSON == true ? JSON.encode(data) : data);
			});
		} else return file.writeAsString(isJSON == true ? JSON.encode(data) : data);
	
	}
	
	/**
	 * Reset push-based variables to their default values.
	 */
	void reset() {
		
		this.fetchRequestResponses = 0;
		this.rawMatchCount = 0;
		this.totalFetchResponseTime = 0;
		
		this.filteredMatchCount = 0;
		this.matchProcessingDelay = 0.00;
		this.downtimeSinceLastPush = 0;
		this.rejectedMatchCounts = [0, 0, 0, 0];
		
	}
	
}