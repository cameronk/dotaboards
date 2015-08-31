<?php

use Illuminate\Auth\UserInterface;

class Player extends Eloquent implements UserInterface {

	public function scopeExists($id64) {
		return Player::where('steam64', $id64)->get()->count() > 0;
	}

	/**
	 * Get the unique identifier for the user.
	 *
	 * @return mixed
	 */
	public function getAuthIdentifier()
	{
		return $this->getKey();
	}

	/**
	 * Get the password for the user.
	 *
	 * @return string
	 */
	public function getAuthPassword()
	{
		return $this->password;
	}

	/**
	 * Get the e-mail address where password reminders are sent.
	 *
	 * @return string
	 */
	public function getReminderEmail()
	{
		return $this->email;
	}

	public function getRememberToken() 
	{

	}
	public function setRememberToken($value) 
	{

	}
	public function getRememberTokenName() 
	{

	}
}