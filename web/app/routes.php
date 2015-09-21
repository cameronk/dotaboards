<?php

/*
|--------------------------------------------------------------------------
| Application Routes
|--------------------------------------------------------------------------
|
| Here is where you can register all of the routes for an application.
| It's a breeze. Simply tell Laravel the URIs it should respond to
| and give it the Closure to execute when that URI is requested.
|
*/

$domain = Config::get('app.domain');

Route::group(array('domain' => '{region}.' . $domain), function() {
	Route::get('/', function($region) {
		$region = strtolower($region);
		$agent = !Agent::isMobile() ? 'primary' : 'mobile';

		if(in_array($region, ["global", "us", "eu", "asia", "africa", "russia", "south-america", "aus"])) {
			return View::make("layouts." . $agent, array('index' => true))->nest('child', 'boards/'. $region . '-' . $agent);
		} else return App::abort(404);
	});
});




Route::get('/', array('uses' => 'PageController@index'));
Route::get('signin', array('uses' => 'PageController@signin'));
Route::get('signout', function() { Session::flush(); return Redirect::to('/'); });
Route::get('stats', array('uses' => 'PageController@stats'));
Route::get('down', function() { return View::make('down'); });
Route::get('charts', array('uses' => 'PageController@charts'));


Route::group(array('prefix' => 'region'), function() {
	Route::get('back', function() {
		Session::forget('asked');
		return Redirect::to(Config::get('app.domain'))->withCookie(Cookie::forget('region'));
	});
	Route::post('set', function() {
		$region = Input::get('region');
		return Response::json(array('success' => true))->withCookie(Cookie::forever('region', $region));
	});
	Route::post('nope', function() {
		$region = Input::get('region');
		Session::put('asked.'. $region, true);
		return Response::json(array('success' => true));
	});
});
// Route::get('region/back', function() {
// 	Session::forget('asked');
// 	return Redirect::to("/")->withCookie(Cookie::forget('region'));
// });
// Route::get('region/set/{region}', function($region) {
// 	return Redirect::to("http://" . $region . "." . $domain)->withCookie(Cookie::make('region', $region));
// });
// Route::get('region/nope/{region}', function($region) {
// 	Session::put('asked.'. $region, true);
// 	return Redirect::to("http://" . $region . "." . $domain);
// });