library pool;

import "dart:async";
import "package:sqljocky/sqljocky.dart";
import "../util/util.dart";

part "queryhelper.dart";
part "queryerror.dart";

class Pool {
	
	Pool() {
		ENV.log("Initialized new pool instance.", type: 4);
	}
	
	ConnectionPool create() => new ConnectionPool(host: ENV.dbHost, port: ENV.dbPort, user: ENV.dbUser, password: ENV.dbPass, db: ENV.db);
	
}