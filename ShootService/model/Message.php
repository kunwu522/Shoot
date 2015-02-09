<?php
/**
 * model for message
 */
class Message
{
	private $id;
	private $message;
	private $sender_id;
	private $receiver_id;
	private $time;
	private $deleted;
	private $type;
	private $related_shoot_id;
	private $related_user_id;
	private $is_read;
	private $image_metadata;
	
	public static $MESSAGE_TYPE_NOTIFICATION = 'notification';
	public static $MESSAGE_TYPE_MESSAGE = 'message';
	
	public function get_id() {
		return $this->id;
	}
	
	public function set_id($id) {
		$this->id = $id;
	}
	
	public function get_sender_id() {
		return $this->sender_id;
	}
	
	public function set_sender_id($sender_id) {
		$this->sender_id = $sender_id;
	}
	
	public function get_receiver_id() {
		return $this->receiver_id;
	}
	
	public function set_receiver_id($receiver_id) {
		$this->receiver_id = $receiver_id;
	}
	
	public function get_message() {
		return $this->message;
	}
	
	public function set_message($message) {
		$this->message = $message;
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
	
	public function get_type() {
		return $this->type;
	}
	
	public function set_type($type) {
		$this->type = $type;
	}
	
	public function get_related_shoot_id() {
		return $this->related_shoot_id;
	}
	
	public function set_related_shoot_id($related_shoot_id) {
		$this->related_shoot_id = $related_shoot_id;
	}
	
	public function get_related_user_id() {
		return $this->related_user_id;
	}
	
	public function set_related_user_id($related_user_id) {
		$this->related_user_id = $related_user_id;
	}
	
	public function get_is_read() {
		return $this->is_read;
	}
	
	public function set_is_read($is_read) {
		$this->is_read = $is_read;
	}
	
	public function get_image_metadata()
	{
		return $this->image_metadata;
	}
	
	public function set_image_metadata($image_metadata)
	{
		$this->image_metadata = $image_metadata;
	}
}

?>