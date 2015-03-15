<?php
/**
 * model for comment
 */
class Comment
{
	private $id;
	private $shoot_id;
	private $user_id;
	private $time;
	private $deleted;
	private $like_count;
	private $content;
	private $x;
	private $y;
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_id($id) {
		$this->id = $id;
	}
	
	public function get_shoot_id() {
		return $this->shoot_id;
	}
	
	public function set_shoot_id($shoot_id) {
		$this->shoot_id = $shoot_id;
	}
	
	public function get_user_id() {
		return $this->user_id;
	}
	
	public function set_user_id($user_id) {
		$this->user_id = $user_id;
	}
	
	public function get_content() {
		return $this->content;
	}
	
	public function set_content($content) {
		$this->content = $content;
	}
	
	public function get_time() {
		return $this->time;
	}
	
	public function set_time($time) {
		$this->time = $time;
	}
	
	public function get_deleted() {
		return $this->deleted;
	}
	
	public function set_deleted($deleted) {
		$this->deleted = $deleted;
	}
	
	public function get_x() {
		return $this->x;
	}
	
	public function set_x($x) {
		$this->x = $x;
	}
	
	public function get_y() {
		return $this->y;
	}
	
	public function set_y($y) {
		$this->y = $y;
	}
	
	public function get_like_count() {
		return $this->like_count;
	}
	
	public function set_like_count($like_count) {
		$this->like_count = $like_count;
	}
}

?>