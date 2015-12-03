library util;

import "dart:io";
import "dart:math";
import "dart:async";
import "dart:convert";
import "../processor/processor.dart";
import "../request/dispatcher.dart";
//import "package:mailer/mailer.dart";

part "state.dart";
part "static.dart";
part "environment.dart";


class Util {

	
	/**
	 * Print an error
	 */
	void printError(e) {
		
		print("\n======================================================");
		print("Error:");
		print("      ${e.toString()}");
		print("\n");
		print("======================================================\n");
	}
	
	
	
	/**
	 * Convert a duration (seconds) into a formatted length timestamp.
	 */
	String secondsToTime(int sec){
		
		double min 		= sec / 60;
		String hours	= (min / 60).floor() > 0 ? (min / 60).floor().toString() + ":" : "";
		int minutes 	= min.floor() - (60 * (min / 60).floor());
		int seconds 	= ((min - min.floor()) * 60).ceil();
		
		return hours + 
			(minutes < 10 ? "0" + minutes.toString() : minutes.toString() ) + ":" +
			(seconds < 10 ? "0" + seconds.toString() : seconds.toString() );
		
	}

	
	/**
	 * Return a short (fixed double with precision 1) version of the integer.
	 */
	String intToShort(dynamic<int, double> i) => (i / 1000) > 1 ? (i / 1000).toStringAsFixed(1) : "<1";

	
	/**
	 * Get the respective integer's verbal suffix.
	 */
	String intAddSuffix(int i) {
		if(i > 3 && i < 21) return 'th';
		switch (i % 10) {
			case 1:  return "st";
			case 2:  return "nd";
			case 3:  return "rd";
			default: return "th";
		}       
	}
	
	
	/**
	 * Get the string name of the cluster location for this cluster ID.
	 */
	String getCluster([int id=0]) {
		if		(id >= 110 && id < 120) return "US-W";
		else if	(id >= 120 && id < 130) return "US-E";
		else if (id >= 130 && id < 140) return "EU-W";
		else if (id >= 140 && id < 150) return "South Korea";
		else if (id >= 150 && id < 160) return "SE-Asia";
		else if (id >= 160 && id < 170) return "China";
		else if (id >= 170 && id < 180) return "Australia";
		else if (id >= 180 && id < 190) return "Russia";
		else if (id >= 190 && id < 200) return "EU-E";
		else if (id >= 200 && id < 210) return "South America";
		else if (id >= 210 && id < 220) return "South Africa";
		else if (id >= 220 && id < 240) return "China";
		else return "Unknown";
	}
	

	
	/**
	 * Convert an int id32 into a 64-bit ID.
	 */
	int to64(int id32) => id32 + 76561197960265728;
	
	/**
	 * Send a text
	 */
//	void text(String message) {
//		
//		print(" ==> PREPARING TO TEXT");
//		
//		var options = new SmtpOptions()
//			..username = "noreply@azuru.me"
//			..password = "replynone143"
//			..hostName = "mail.azuru.me"
//			..port     = 25;
//		
//		var emailTransport = new SmtpTransport(options);
//		
//		var envelope = new Envelope()
//			..from = "noreply@azuru.me"
//			..recipients.add('6159279383@messaging.sprintpcs.com')
//			..subject = ""
//			..text = message;
//		
//		emailTransport.send(envelope)
//		    .then((success) => print('Email sent! $success'))
//	        .catchError((e) => print('Error occured: $e'));
//	}
	
}