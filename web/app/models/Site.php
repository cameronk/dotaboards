<?php
class Site extends Eloquent {
	protected $table = "site";
	public function getDates() {
		return array('steam_down_at');
	}
}