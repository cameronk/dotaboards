<?php
class Appearance extends Eloquent {

	protected $table = "appearances";

	public function getDates() {
		return array('updated');
	}
}