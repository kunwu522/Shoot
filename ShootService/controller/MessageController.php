<?php
// ini_set('display_errors',1);
// error_reporting(E_ALL);
include './library/ImageHandler.php';

class MessageController extends Controller
{
	protected $message_dao;
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->message_dao = new MessageDAO();
    }
	
	public function query() {
		$currentUser_id = $this->getCurrentUser();
		$messages = $this->message_dao->query($currentUser_id);
	    return json_encode(array('messages' => $messages));
	}
	
	public function read($message_id) {
		$currentUser_id = $this->getCurrentUser();
		$this->message_dao->mark_message_as_read($currentUser_id, $message_id);
	}
	
	public function create() {
		$data = $this->parse_create_request_body();
		$message = $this->convert_data_to_message($data);
		$currentUser_id = $this->getCurrentUser();
		if ($currentUser_id == $message->get_receiver_id()) {
			throw new InvalidRequestException('Can not send message to yourself.'); 
		}
		$notification_message = $this->getCurrentUsername() . ':' . $message->get_message();
		$id = $this->message_dao->create($message, $notification_message);
	    return json_encode(array('id' => $id));
	}
	
	public function upload($receiver_id)
	{
		$currentUser_id = $this->getCurrentUser();
		$message = new Message();
		$message->set_sender_id($currentUser_id);
		$message->set_receiver_id($receiver_id);
		$message->set_type(Message::$MESSAGE_TYPE_MESSAGE);
		list($width, $height) = getimagesize( $_FILES['image']['tmp_name']);
		$metadata = array('width'=>$width, 'height'=>$height);
		$message->set_image_metadata(json_encode($metadata));	
		error_log('Image name: ' . $_FILES['image']['name']);
		error_log('Image width: ' . $width);
		error_log('Image height: ' . $height);
		error_log('Image type: ' . $_FILES['image']['type']);
		error_log('Image size: ' . $_FILES['image']['size']);
		error_log('Image tmp name: ' . $_FILES['image']['tmp_name']);
		$notification_message = $this->getCurrentUsername() . ' sent you a photo';
		$message_id = $this->message_dao->create($message, $notification_message);
		$_FILES['image']['name'] = $message_id . ".jpeg";
		if (!saveImageForMessageToServer($_FILES['image'], $currentUser_id, $message_id)) {
			$this->message_dao->delete($message_id);
			throw new DependencyFailureException('Failed to upload image for message ' . $message_id);
		}
		$messages = $this->message_dao->query($currentUser_id, $message_id);
	    return json_encode($messages[0]);
	}
	
	private function parse_create_request_body() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('create message request has to be either POST or PUT.');
		}
		
		$data = json_decode(file_get_contents('php://input'));
		$invalidReason = $this->check_para($data);
		if ($invalidReason) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
		}
		return $data;
	}
	
	private function convert_data_to_message($data) {
		$currentUser_id = $this->getCurrentUser();
		$message = new Message();
		$message->set_message($data->message);
		$message->set_sender_id($currentUser_id);
		$message->set_receiver_id($data->participant->id);
		$message->set_time($data->time);
		$message->set_type(Message::$MESSAGE_TYPE_MESSAGE);
		return $message;
	}
	
	private function check_para($data)
	{	
		$participant = $data->participant;
		if ($participant == null) {
			return 'Input error, participant is null';
		}
		
		$message = trim($data->message);
		if ($message == '') {
			return 'Input error, message is null';
		}
		
		if ($participant->id == null) {
			return 'Input error, participant.id is null';
		}
		return null;		
	}
}

?>