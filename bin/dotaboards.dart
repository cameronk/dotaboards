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

		ENV.log("________          __        ___.                          .___      ");
		ENV.log("\______ \   _____/  |______ \_ |__   _________ _______  __| _/______");
		ENV.log(" |    |  \ /  _ \   __\__  \ | __ \ /  _ \__  \\_  __ \/ __ |/  ___/");
		ENV.log(" |    `   (  <_> )  |  / __ \| \_\ (  <_> ) __ \|  | \/ /_/ |\___ \ ");
		ENV.log("/_______  /\____/|__| (____  /___  /\____(____  /__|  \____ /____  >");
		ENV.log("         \/                 \/    \/           \/           \/    \/");
		ENV.log("====================================================================");
		ENV.log("			ENV: ${$ENV}");
		ENV.log("====================================================================");
		
	
		var util = new Util();
		
		ConnectionPool pool = new Pool().create();
		var queries = new QueryHelper(pool);
		
		queries.truncateMatches()
			.then((_) => queries.retrieveBans())
			.then((list) {
				new Dispatcher(list, queries);
				return true;
			});
		
	});
	
}