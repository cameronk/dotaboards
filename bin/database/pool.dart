library pool;

import "dart:async";

import "package:sqljocky/sqljocky.dart";

part "queryhelper.dart";
part "queryerror.dart";

class Pool {
	
	String host 	= "127.0.0.1";
	int port 		= 3306;
	String password;
	String user;
	String db		= "dotaboards_main";
	
	Pool(String $ENV) {
		print("Initialized new pool instance.");
		
		if($ENV == "TESTING" || $ENV == "LOCAL") {
			print("Pool: Using testing environment");
			this.user 		= "cameron-dota";
			this.password 	= "9238283762313586";
			this.db			= "cameron-dota";
		} else {
			this.user		= "root";
			this.password 	= r"uruza852@jk$uck$d1k";
		}
	}
	
	ConnectionPool create() => new ConnectionPool(host: this.host, port: this.port, user: this.user, password: this.password, db: this.db);
	
}