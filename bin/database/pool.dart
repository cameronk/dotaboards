library pool;

import "dart:async";
import "package:sqljocky/sqljocky.dart";
import "../util/util.dart";

part "queryhelper.dart";
part "queryerror.dart";

class Pool {
	
//	String host 	= "127.0.0.1";
//	int port 		= 3306;
//	String password;
//	String user;
//	String db		= "dotaboards_main";
	
	Pool() {
		ENV.log("Initialized new pool instance.", 4);
		
//		if(ENV.name == "TESTING" || ENV.name == "LOCAL") {
//			print("Pool: Using testing environment");
//			this.user 		= "cameron-dota";
//			this.password 	= "9238283762313586";
//			this.db			= "cameron-dota";
//		} else {
//			this.user		= "root";
//			this.password 	= r"uruza852@jk$uck$d1k";
//		}
	}
	
	ConnectionPool create() => new ConnectionPool(host: ENV.dbHost, port: ENV.dbPort, user: ENV.dbUser, password: ENV.dbPass, db: ENV.db);
	
}