library dotaboards;

import "package:sqljocky/sqljocky.dart";

import "request/dispatcher.dart";
import "database/pool.dart";
import "util/util.dart";

String $ENV = "PRODUCTION";

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
	

	print("________          __        ___.                          .___      ");
	print("\______ \   _____/  |______ \_ |__   _________ _______  __| _/______");
	print(" |    |  \ /  _ \   __\__  \ | __ \ /  _ \__  \\_  __ \/ __ |/  ___/");
	print(" |    `   (  <_> )  |  / __ \| \_\ (  <_> ) __ \|  | \/ /_/ |\___ \ ");
	print("/_______  /\____/|__| (____  /___  /\____(____  /__|  \____ /____  >");
	print("         \/                 \/    \/           \/           \/    \/");
	print("====================================================================");
	print("					             ENV: ${$ENV}							");
	print("====================================================================");
	

	var util = new Util();
	ConnectionPool pool = new Pool($ENV).create();
	var queries = new QueryHelper(pool);
	
	queries.truncateMatches()
		.then((_) => queries.retrieveBans())
		.then((list) {
			new Dispatcher(list, queries);
			return true;
		});
	
}