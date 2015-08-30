<?php
class PageController extends BaseController {

	public $agent = "primary";

	public function __construct() {
		$this->agent = !Agent::isMobile() ? 'primary' : 'mobile';
	}


	public function index() {

		if(!Cookie::get('region')) {
			$contents = "{}";
			try {
				$contents = File::get("../../daemon/storage/players-processed.json");
			} catch(Exception $e) {
				App::abort(500, "An internal error occurred.");
				Log::error("players-processed.json not found");
			} finally {
				return View::make("regions-" . $this->agent, array('regions' => $contents));
			}
		} else return Redirect::to("http://" . Cookie::get('region') . ".dotaboards.com");

		// return View::make("regions");
	}

	public function charts() {

		$contents = "{}";
		try {
			$contents = File::get("../../daemon/storage/monitor.json");
		} catch(Exception $e) {
			App::abort(500, "An internal error occurred.");
			Log::error("monitor.json not found");
		} finally {
			return View::make("charts", array('regions' => $contents));
		}

	}


	public function signin() {
		$openid = new LightOpenID(URL::to('/signin'));
		if(!$openid->mode) {
            $openid->identity = 'http://steamcommunity.com/openid/?l=english'; 
            return Redirect::to($openid->authUrl());
		} elseif($openid->mode == 'cancel') {
			echo "User cancelled";
		} else {
			if($openid->validate()) {
				$id = $openid->identity;
				$get = file_get_contents("http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key=E03B7DAF68C03DFF4745BF4213BC8672&steamids=" . substr($id, 36));
				$data = json_decode($get);
				foreach($data->response->players as $player) {
					$p = Player::where('steam64', $player->steamid);
					if($p->count() == 0) {
						$p = new Player;
							$p->steam32 = ((int) $player->steamid) - 76561197960265728;
							$p->steam64 = $player->steamid;
							$p->persona = $player->personaname;
							$p->avatar  = $player->avatarfull;
							$p->save();
					} else {
						$p = $p->first();
						$p->persona = $player->personaname;
						$p->avatar  = $player->avatarfull;
						$p->save();
					}
					if(Auth::loginUsingId($p->id)) {
						return Redirect::to('/');
					} else {
						echo "Something went wrong. <a href='/'>Try again</a>";
					}
				}
			} else return Redirect::to($openid->authUrl());
		}
	}

	public function stats() {
		//-latest-primary
		return View::make('layouts.primary', array('index' => false, 'css' => array('stats')))->nest('child', 'stats');
	}
}