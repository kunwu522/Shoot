<?php

// ini_set('display_errors',1);
// error_reporting(E_ALL);

include './library/ImageHandler.php';

class ShootController extends Controller
{
	protected $shoot_dao;
	protected $message_dao;
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->shoot_dao = new ShootDAO();
		$this->message_dao = new MessageDAO();
    }
	
	public function query($user_id) {
		$current_user_id = $this->getCurrentUser();
		$shoots = $this->shoot_dao->query($current_user_id, $user_id, null);
		return json_encode(array('shoots'=>$shoots));
	}
	
	public function queryByContent($keyword) {
		$current_user_id = $this->getCurrentUser();
		$shoots = $this->shoot_dao->query($current_user_id, null, $keyword);
		return json_encode(array('shoots'=>$shoots));
	}
	
	public function trends() {
		$current_user_id = $this->getCurrentUser();
		$shoots = $this->shoot_dao->trends($current_user_id);
		foreach ($shoots as &$shoot) {
			$relationship = $this->user_dao->getRelationship($current_user_id, $shoot['user_id']);
			$shoot['relationship_with_currentUser'] = $relationship;
		}
		return json_encode(array('shoots'=>$shoots));
	}
	
	public function queryById($user_id, $shoot_id) {
		$shoot = $this->shoot_dao->queryById($user_id, $shoot_id);
		return json_encode(array('shoots'=>$shoot));
	}
	
	public function create($parameters) 
	{
		//parse request body
		$shoot = $this->parse_request_body($parameters, true);
		
		//Save shoot to db
		$shoot_id = $this->shoot_dao->create($shoot);
		
		//Save images
		try {
			$files = $parameters["files"];
			if (isset($files)) {
				foreach($files as $id => $file) {
					$this->upload_shoot_image($file, $shoot->get_user_id(), $shoot_id);
				}
			}
		} catch (Exception $e) {
			$this->delete($shoot_id);
			throw $e;
		}
		
		return json_encode(array('id' => $shoot_id));
	}
	
	public function tag_shoot($parameters) {
		$shoot = $this->parse_request_body($parameters, false);
		$currentUser_id = $this->getCurrentUser();
		$currentUsername = $this->getCurrentUsername();
		$this->shoot_dao->setUserTagsShoot($currentUser_id, $shoot->get_id(), $shoot->get_tags(), ShootDAO::$TYPE_WANT, $shoot->get_latitude(), $shoot->get_longitude());
		//do not notify the owner of the shoot for now
		// $shoot = $this->shoot_dao->find_shoot_by_id($shoot_id)[0];
// 		if ($shoot['user_id'] != $currentUser_id) {
// 			$message = new Message();
// 			$message->set_message('@' . $currentUsername . ' wanted your post: ' . $shoot['content']);
// 			$message->set_sender_id($currentUser_id);
// 			$message->set_receiver_id($shoot['user_id']);
// 			$message->set_time(date('Y-m-d H:i:s'));
// 			$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
// 			$message->set_related_shoot_id($shoot_id);
// 			$notification_message = $message->get_message();
// 			$this->message_dao->create($message, $notification_message);
// 		}
	}
	
	public function untag_shoot($shoot_id, $tag_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$this->shoot_dao->setUserUntagShoot($currentUser_id, $shoot_id, $tag_id);
	}
	
	public function queryShootById($shoot_id) 
	{
		return json_encode($this->shoot_dao->find_shoot_by_id($shoot_id));
	}
	
	public function like($shoot_id) 
	{
		$currentUser_id = $this->getCurrentUser();
		$currentUsername = $this->getCurrentUsername();
		$this->shoot_dao->setUserLikeShoot($currentUser_id, $shoot_id);
		$shoot = $this->shoot_dao->find_shoot_by_id($shoot_id)[0];
		if ($shoot['user_id'] != $currentUser_id) {
			$message = new Message();
			$message->set_message('@' . $currentUsername . ' liked your post: ' . $shoot['content']);
			$message->set_sender_id($currentUser_id);
			$message->set_receiver_id($shoot['shoot_user_id']);
			$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
			$message->set_related_shoot_id($shoot_id);
			$notification_message = $message->get_message();
			$this->message_dao->create($message, $notification_message);
		}
	}
	
	public function unlike($shoot_id) 
	{		
		$currentUser_id = $this->getCurrentUser();
		$this->shoot_dao->setUserUnlikeShoot($currentUser_id, $shoot_id);
	}
	
	private function parse_request_body($parameters, $check_param) {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('request has to be either POST or PUT.');
		}
		if($check_param) {
			$invalidReason = $this->check_para($parameters);
			if ($invalidReason) {
				throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
			}
		}
		
		$shoot = new shoot();
		$shoot->set_content($parameters["content"]);
		$shoot->set_user_id($parameters["user_id"]);
		$shoot->set_id($parameters["id"]);
		$shoot->set_deleted(0);		
		$shoot->set_latitude($parameters["latitude"]);
		$shoot->set_longitude($parameters["longitude"]);
		
		$tags = array();
		if (isset($parameters["tags"])) {
			foreach ($parameters["tags"] as $tag) {
				$tags[] = $tag;
			}
		} 
		$shoot->set_tags($tags);		
		
		
		return $shoot;
	}
	
	private function check_para($data)
	{
		$content = trim($data['content']);
		if ($content == '') {
			return 'Input error, content is null';
		}
		
		$user_id = trim($data['user_id']);
		if ($user_id == '') {
			return 'Input error, userid is null';
		}
		
		$latitude = trim($data['latitude']);
		if ($latitude == '') {
			return 'Input error, latitude is null';
		}
		
		$longitude = trim($data['longitude']);
		if ($longitude == '') {
			return 'Input error, longitude is null';
		}
		
		$tags = $data['tags'];
		if ($tags == '') {
			return 'Input error, tags is null';
		}
		
		return null;		
	}
	
	private function upload_shoot_image($file, $user_id, $shoot_id)
	{
		error_log('Image name: ' . $file['name']);
		error_log('Image type: ' . $file['type']);
		error_log('Image size: ' . $file['size']);
		error_log('Image tmp name: ' . $file['tmp_name']);

		if (!saveImageForshootsToServer($file, $user_id, $shoot_id)) {
			throw new DependencyFailureException('Failed to upload image for shoot ' . $shoot_id);
		}
	}
}
?>