part of util;

class Environment {
	
	/**
	 * The environment specified at launch
	 */
	String name;
	String hash;
	File logFile;
	IOSink sink;
	String pushMode = "normal";
	
	
	/**
	 * Storage locations
	 */
	String AppDirectory;
	String StorageDirectory;
	
	/**
	 * Database config
	 */
	String dbHost;
	int dbPort = 3306;
	String dbUser;
	String dbPass;
	String db;
	
	/**
	 * Region maps
	 */
	final Map<String, List<String>> RegionMap = {
    	"us": ["US-W", "US-E"],
    	"eu": ["EU-W", "EU-E"],
    	"asia": ["South Korea", "SE-Asia", "China"],
    	"africa": ["South Africa"],
    	"russia": ["Russia"],
    	"south-america": ["South America"],
    	"aus": ["Australia"]
    };
	final Map<String, String> RegionMapReverse = {
    	"US-W": "us",
    	"US-E": "us",
    	"EU-W": "eu",
    	"EU-E": "eu",
    	"South Korea": "asia",
    	"SE-Asia": "asia",
    	"China": "asia",
    	"South Africa": "africa",
    	"Russia": "russia",
    	"South America": "south-america",
    	"Australia": "aus"
    };
	final Map<String, String> RegionIdentifiers = {
    	"us": "USA",
    	"eu": "European",
    	"asia": "Asian",
    	"africa": "African",
    	"russia": "Russian",
    	"south-america": "South American",
    	"aus": "Australian"
    };
	final Map<String, String> RegionIdentifiersSingular = {
    	"us": "USA",
    	"eu": "Europe",
    	"asia": "Asia",
    	"africa": "Africa",
    	"russia": "Russia",
    	"south-america": "South America",
    	"aus": "Australia"
    };
	
	/**
	 * Heroes
	 */
	final Map<String,List> Heroes = {
	 "0": [
	   null,
	   "Unknown"
	 ],
	 "1": [
	   "antimage",
	   "Antimage"
	 ],
	 "2": [
	   "axe",
	   "Axe"
	 ],
	 "3": [
	   "bane",
	   "Bane"
	 ],
	 "4": [
	   "bloodseeker",
	   "Bloodseeker"
	 ],
	 "5": [
	   "crystal_maiden",
	   "Crystal Maiden"
	 ],
	 "6": [
	   "drow_ranger",
	   "Drow Ranger"
	 ],
	 "7": [
	   "earthshaker",
	   "Earthshaker"
	 ],
	 "8": [
	   "juggernaut",
	   "Juggernaut"
	 ],
	 "9": [
	   "mirana",
	   "Mirana"
	 ],
	 "10": [
	   "morphling",
	   "Morphling"
	 ],
	 "11": [
	   "nevermore",
	   "Shadow Fiend"
	 ],
	 "12": [
	   "phantom_lancer",
	   "Phantom Lancer"
	 ],
	 "13": [
	   "puck",
	   "Puck"
	 ],
	 "14": [
	   "pudge",
	   "Pudge"
	 ],
	 "15": [
	   "razor",
	   "Razor"
	 ],
	 "16": [
	   "sand_king",
	   "Sand King"
	 ],
	 "17": [
	   "storm_spirit",
	   "Storm Spirit"
	 ],
	 "18": [
	   "sven",
	   "Sven"
	 ],
	 "19": [
	   "tiny",
	   "Tiny"
	 ],
	 "20": [
	   "vengefulspirit",
	   "Vengeful Spirit"
	 ],
	 "21": [
	   "windrunner",
	   "Windranger"
	 ],
	 "22": [
	   "zuus",
	   "Zeus"
	 ],
	 "23": [
	   "kunkka",
	   "Kunkka"
	 ],
	 "25": [
	   "lina",
	   "Lina"
	 ],
	 "26": [
	   "lion",
	   "Lion"
	 ],
	 "27": [
	   "shadow_shaman",
	   "Shadow Shaman"
	 ],
	 "28": [
	   "slardar",
	   "Slardar"
	 ],
	 "29": [
	   "tidehunter",
	   "Tidehunter"
	 ],
	 "30": [
	   "witch_doctor",
	   "Witch Doctor"
	 ],
	 "31": [
	   "lich",
	   "Lich"
	 ],
	 "32": [
	   "riki",
	   "Riki"
	 ],
	 "33": [
	   "enigma",
	   "Enigma"
	 ],
	 "34": [
	   "tinker",
	   "Tinker"
	 ],
	 "35": [
	   "sniper",
	   "Sniper"
	 ],
	 "36": [
	   "necrolyte",
	   "Necrophos"
	 ],
	 "37": [
	   "warlock",
	   "Warlock"
	 ],
	 "38": [
	   "beastmaster",
	   "Beastmaster"
	 ],
	 "39": [
	   "queenofpain",
	   "Queen of Pain"
	 ],
	 "40": [
	   "venomancer",
	   "Venomancer"
	 ],
	 "41": [
	   "faceless_void",
	   "Faceless Void"
	 ],
	 "42": [
	   "skeleton_king",
	   "Wraith King"
	 ],
	 "43": [
	   "death_prophet",
	   "Death Prophet"
	 ],
	 "44": [
	   "phantom_assassin",
	   "Phantom Assassin"
	 ],
	 "45": [
	   "pugna",
	   "Pugna"
	 ],
	 "46": [
	   "templar_assassin",
	   "Templar Assassin"
	 ],
	 "47": [
	   "viper",
	   "Viper"
	 ],
	 "48": [
	   "luna",
	   "Luna"
	 ],
	 "49": [
	   "dragon_knight",
	   "Dragon Knight"
	 ],
	 "50": [
	   "dazzle",
	   "Dazzle"
	 ],
	 "51": [
	   "rattletrap",
	   "Clockwerk"
	 ],
	 "52": [
	   "leshrac",
	   "Leshrac"
	 ],
	 "53": [
	   "furion",
	   "Nature&#39;s Prophet"
	 ],
	 "54": [
	   "life_stealer",
	   "Lifestealer"
	 ],
	 "55": [
	   "dark_seer",
	   "Dark Seer"
	 ],
	 "56": [
	   "clinkz",
	   "Clinkz"
	 ],
	 "57": [
	   "omniknight",
	   "Omniknight"
	 ],
	 "58": [
	   "enchantress",
	   "Enchantress"
	 ],
	 "59": [
	   "huskar",
	   "Huskar"
	 ],
	 "60": [
	   "night_stalker",
	   "Night Stalker"
	 ],
	 "61": [
	   "broodmother",
	   "Broodmother"
	 ],
	 "62": [
	   "bounty_hunter",
	   "Bounty Hunter"
	 ],
	 "63": [
	   "weaver",
	   "Weaver"
	 ],
	 "64": [
	   "jakiro",
	   "Jakiro"
	 ],
	 "65": [
	   "batrider",
	   "Batrider"
	 ],
	 "66": [
	   "chen",
	   "Chen"
	 ],
	 "67": [
	   "spectre",
	   "Spectre"
	 ],
	 "68": [
	   "ancient_apparition",
	   "Ancient Apparition"
	 ],
	 "69": [
	   "doom_bringer",
	   "Doom"
	 ],
	 "70": [
	   "ursa",
	   "Ursa"
	 ],
	 "71": [
	   "spirit_breaker",
	   "Spirit Breaker"
	 ],
	 "72": [
	   "gyrocopter",
	   "Gyrocopter"
	 ],
	 "73": [
	   "alchemist",
	   "Alchemist"
	 ],
	 "74": [
	   "invoker",
	   "Invoker"
	 ],
	 "75": [
	   "silencer",
	   "Silencer"
	 ],
	 "76": [
	   "obsidian_destroyer",
	   "Outworld Devourer"
	 ],
	 "77": [
	   "lycan",
	   "Lycan"
	 ],
	 "78": [
	   "brewmaster",
	   "Brewmaster"
	 ],
	 "79": [
	   "shadow_demon",
	   "Shadow Demon"
	 ],
	 "80": [
	   "lone_druid",
	   "Lone Druid"
	 ],
	 "81": [
	   "chaos_knight",
	   "Chaos Knight"
	 ],
	 "82": [
	   "meepo",
	   "Meepo"
	 ],
	 "83": [
	   "treant",
	   "Treant"
	 ],
	 "84": [
	   "ogre_magi",
	   "Ogre Magi"
	 ],
	 "85": [
	   "undying",
	   "Undying"
	 ],
	 "86": [
	   "rubick",
	   "Rubick"
	 ],
	 "87": [
	   "disruptor",
	   "Disruptor"
	 ],
	 "88": [
	   "nyx_assassin",
	   "Nyx Assassin"
	 ],
	 "89": [
	   "naga_siren",
	   "Naga Siren"
	 ],
	 "90": [
	   "keeper_of_the_light",
	   "Keeper of the Light"
	 ],
	 "91": [
	   "wisp",
	   "Io"
	 ],
	 "92": [
	   "visage",
	   "Visage"
	 ],
	 "93": [
	   "slark",
	   "Slark"
	 ],
	 "94": [
	   "medusa",
	   "Medusa"
	 ],
	 "95": [
	   "troll_warlord",
	   "Troll Warlord"
	 ],
	 "96": [
	   "centaur",
	   "Centaur"
	 ],
	 "97": [
	   "magnataur",
	   "Magnus"
	 ],
	 "98": [
	   "shredder",
	   "Timbersaw"
	 ],
	 "99": [
	   "bristleback",
	   "Bristleback"
	 ],
	 "100": [
	   "tusk",
	   "Tusk"
	 ],
	 "101": [
	   "skywrath_mage",
	   "Skywrath Mage"
	 ],
	 "102": [
	   "abaddon",
	   "Abaddon"
	 ],
	 "103": [
	   "elder_titan",
	   "Elder Titan"
	 ],
	 "104": [
	   "legion_commander",
	   "Legion Commander"
	 ],
	 "105": [
	   "techies",
	   "Techies"
	 ],
	 "106": [
	   "ember_spirit",
	   "Ember Spirit"
	 ],
	 "107": [
	   "earth_spirit",
	   "Earth Spirit"
	 ],
	 "109": [
	   "terrorblade",
	   "Terrorblade"
	 ],
	 "110": [
	   "phoenix",
	   "Phoenix"
	 ],
	 "111": [
	   "oracle",
	   "Oracle"
	 ],
	 "112": [
	   "winter_wyvern",
	   "Winter Wyvern"
	 ]
   };
	
	
	/**
	 * Match-related
	 */
	final Map<String,String> LobbyTypes = {
    	"-1":"Invalid",
    	"0":"Public Matchmaking", 
    	"1":"Practice", 
    	"2":"Tournament", 
    	"3":"Tutorial",
    	"4":"Co-op with Bots", 
    	"5":"Team match", 
    	"6":"Solo queue", 
    	"7":"Ranked", 
    	"8":"Solo mid 1v1", 
    };

    final Map<String,String> GameModes = {
    	"0":"Unknown", 
    	"1":"All Pick", 
    	"2":"Captains Mode", 
    	"3":"Random Draft",
    	"4":"Single Draft", 
    	"5":"All Random", 
    	"6":"?? INTRO/DEATH ??", 
    	"7":"The Diretide", 
    	"8":"Reverse Captains Mode", 
    	"9":"Greeviling", 
    	"10":"Tutorial", 
    	"11":"Mid Only", 
    	"12":"Least Player", 
    	"13":"New Player Pool", 
    	"14":"Compendium Matchmaking", 
    	"15":"Custom", 
    	"16":"Captains Draft", 
    	"17":"Balanced Draft", 
    	"18":"Ability Draft", 
    	"19":"?? Event ??", 
    	"20": "All Random Deathmatch", 
    	"21": "1v1 Solo Mid"
    };
    
    
    /**
     * Boards-related
     */
    final Map<String,List> BoardNames = {
    	"KDA": ["KDA", "KDA"],
    	"GPM": ["GPM", "GPM"],
    	"XPM": ["XPM", "XPM"],
    	"CS": ["Creep Score", "CS"],
    	"HD": ["Hero Damage", "H.D."],
    	"TD": ["Tower Damage", "T.D."],
    	"C2T": ["Credit to Team", "C2T"]
    };
    
	final Map<
		/// Board name ///
		String, 
		Map<
			/// Raw / detailed ///
			String, 
			dynamic<
				/// Raw board ///
				List<
					/// Individual player ///
					List<
						dynamic<
							int, /// player ID
							double /// board value
						>
					>
				>, 
				
				/// Detailed board ///
				Map<
					int, /// player ID 
					Map  /// player-specific info
				>
			>
		>
	> Boards = {
		// Kill-death-assist, gold per min, xp per min, creep score //
		"KDA": {
			"raw": [],
			"det": {}
		},
		"GPM": {
			"raw": [],
			"det": {}
		},
		"XPM": {
			"raw": [],
			"det": {}
		},
		"CS": {
			"raw": [],
			"det": {}
		},
	
		// hero damage, tower damage, credit to team //
		"HD": {
			"raw": [],
			"det": {}
		},
		"TD": {
			"raw": [],
			"det": {}
		},
		"C2T": {
			"raw": [],
			"det": {}
		}
	};
	
	/**
	 * Statistics
	 */
	final Map<String, Map<String, int>>	CumulativeStatistics = {
    	"current": {
    		"kills": 0,
    		"deaths": 0,
    		"assists": 0,
    		"duration": 0,
    	},
    	"total": {
    		"kills": 0,
    		"deaths": 0,
    		"assists": 0,
    		"duration": 0,
    	}
    };
	
	/**
	 * Precision modifiers
	 */
	final Map<String, int> PrecisionModifierMap = { "KDA": 100, "GPM": 1, "XPM": 1, "CS": 100, "HD": 1, "TD": 1, "C2T": 100 }; 

	/**
	 * Rejection reasons
	 */
	List RejectionReasons = ["Levels < 10", "Leavers > 3", "No abilities", "Fake players"];
	

	Environment(String $ENV) {
		
		var rng = new Random();
		
		this.name = $ENV;
		this.hash = new List.generate(8, (_) => rng.nextInt(100)).join();
		
		switch($ENV) {
			case "PRODUCTION":

				/// Setup storage directories ///
				this.AppDirectory 		= "/home/dotaboards/web/app/";
				this.StorageDirectory	= "/home/dotaboards/daemon/storage/";
				

				/// Setup MySQL connection ///
				/// dbHost  = default
				/// dbPort  = default
				this.dbUser = "root";
				this.dbPass = r"uruza852@jk$uck$d1k";
				this.db		= "dotaboards_main";
				
				break;
			case "TESTING-RAZORBACK":

				/// Setup storage directories ///
				this.AppDirectory 		= "/home/razorback/web/app/";
				this.StorageDirectory	= "/home/razorback/daemon/storage/";
				
				/// Setup MySQL connection ///
				/// dbHost  = default
				/// dbPort  = default
				this.dbUser = "cameron-dota";
				this.dbPass = "9238283762313586";
				this.db		= "cameron-dota";
				
				break;
				
			case "TESTING-LANDER":

				/// Setup storage directories ///
				this.AppDirectory 		= "/home/cameron/web/app/";
				this.StorageDirectory	= "/home/cameron/daemon/storage/";
				
				/// Setup MySQL connection ///
				/// dbPort  = default
				this.dbHost = "lander.muny.us";
				this.dbUser = "cameron-dota";
				this.dbPass = "9238283762313586";
				this.db		= "cameron-dota";
				
				break;
				
			case "LOCAL":
				
				/// Setup storage directories ///
				this.AppDirectory 		= "storage/_app/";
				this.StorageDirectory 	= "storage/";

				/// Setup MySQL connection ///
				/// dbPort  = default
				this.dbHost = "lander.muny.us";
				this.dbUser = "cameron-dota";
				this.dbPass = "9238283762313586";
				this.db		= "cameron-dota";
				
				/// Push settings ///
				this.pushMode = "quick";
				
				
				break;
				
			default:
				print("WARNING: Unknown environment ${$ENV}");
				break;
		}
		
	}
	
	Future setup() {
		return new Future(() {
			String fileName = "log-${this.hash}_${new DateTime.now().toIso8601String().replaceAll(":", "")}.txt";
			File log = new File(this.StorageDirectory + "logs/" + fileName);
			
			return log.exists().then((exists) {
				if(exists == false) {
					return log.create().then((File file) {
						this.logFile = file;
						this.sink = file.openWrite();
						return this;
					});
				} else {
					this.logFile = log;
					return this;
				}
			});
		});
	}
	
	void log(String msg, {int type: 0, int level: 1}) {
		
		/**
		 * Types:
		 * 0: no format
		 * 1: block-separated header
		 * 2: wrapped in brackets header
		 * 3:  | message
		 * 4:  > message
		 */
		
		/**
		 * Levels:
		 * 0: message;
		 * 1: important
		 * 2: warning
		 * 3: error
		 */
		
		/**
		 * In testing/local, log everything.
		 * In production, don't log messages.
		 */
		if(this.name != "PRODUCTION" || level != 0) { 

			String message;
		
			switch(type) {
				case 0:
					message = msg;
					break;
				case 1:
					
					String middle = "=====     $msg     =====";
					String side = "";
					for(int i = 0; i < middle.length; i++) {
						side += "=";
					}
					
					message = "$side\n$middle\n$side";
					break;
				case 2:
					message = "[$msg]";
					break;
				case 3:
					message = " | $msg";
					break;
				case 4:
					message = " > $msg";
					break;
				default:
					message = msg;
					break;
				
			}
			
			this.sink.write(message + "\n");
			
			if(this.name == "LOCAL") {
				print(message);
			}
		}
	}
	
	
}