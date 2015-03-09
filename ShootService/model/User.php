<?php
/**
 * @author tony
 *
 */
class User
{
	private $id;
	private $username;
	private $password;
	private $email;
	private $time;
	private $deleted;
	private $followerCount;
	private $followingCount;
	private $wantCount;
	private $haveCount;
	private $has_avatar;
	private $user_type;
	private $has_bg;
	
	public static $TYPE_USER = 'User';
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_id($id) {
		$this->id = $id;
	}
	
	public function get_username() {
		return $this->username;
	}
	
	public function set_username($username) {
		$this->username = $username;
	}
	
	public function get_password() {
		return $this->password;
	}
	
	public function set_password($password) {
		$this->password = $password;
	}
	
	public function get_email() {
		return $this->email;
	}
	
	public function set_email($email) {
		$this->email = $email;
	} 
	
	public function get_time() {
		return $this->time;
	}
	
	public function  set_time($time) {
		$this->time = $time;
	}
	
	public function  get_deleted() {
		return $this->deleted;
	}
	
	public function set_deleted($deleted) {
		$this->deleted = $deleted;
	}
	
	public function  get_followerCount() {
		return $this->followerCount;
	}
	
	public function set_followerCount($followerCount) {
		$this->followerCount = $followerCount;
	}
	
	public function  get_followingCount() {
		return $this->followingCount;
	}
	
	public function set_followingCount($followingCount) {
		$this->followingCount = $followingCount;
	}
	
	public function  get_wantCount() {
		return $this->wantCount;
	}
	
	public function set_wantCount($wantCount) {
		$this->wantCount = $wantCount;
	}
	
	public function  get_haveCount() {
		return $this->haveCount;
	}
	
	public function set_haveCount($haveCount) {
		$this->haveCount = $haveCount;
	}
	
	public function get_has_avatar() {
		return $this->has_avatar;
	}
	
	public function set_has_avatar($has_avatar) {
		$this->has_avatar = $has_avatar;
	}
	
	public function get_user_type() {
		return $this->user_type;
	}
	
	public function set_user_type($user_type) {
		$this->user_type = $user_type;
	}
	
	public function get_has_bg() {
		return $this->has_bg;
	}
	
	public function set_has_bg($has_bg) {
		$this->has_bg = $has_bg;
	}
}
?>