library dotaboards;

import "package:sqljocky/sqljocky.dart";

import "request/dispatcher.dart";
import "database/pool.dart";
import "util/util.dart";

String $ENV = "LOCAL";

String AppDirectory;
String StorageDirectory;


/**
 * Here's where it all gets started.
 * 
 * Initialize basic connection-related variables, clean up database
 * shenanigans, and instantiate dispatchers for handling loop logic.
 */
void main(List<String> args) {
	
	/// Set our environment variable ///
	if(args.length > 0) {
		$ENV = args[0].toUpperCase();
	}
	
	ENV = new Environment($ENV);
	
	ENV.setup().then((_) {
		
		State state = new State();
		
		
		state.Revive().then((_) {
			
			ENV.state = state;
			
    		ENV.log("ENV: ${ENV.name}, hash: ${ENV.hash}", level:1);
    		
    		
    		ConnectionPool pool = new Pool().create();
    		var queries = new QueryHelper(pool);
    		
    		queries.truncateMatches()
    			.then((_) => queries.retrieveBans())
    			.then((list) {
    				new Dispatcher(list, queries);
    				return true;
    			});
			
		});
		
	});
	
}