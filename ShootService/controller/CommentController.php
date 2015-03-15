<?php

// ini_set('display_errors',1);
// error_reporting(E_ALL);

include './library/ImageHandler.php';

class CommentController extends Controller
{
	protected $comment_dao;
	
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->comment_dao = new CommentDAO();
    }
	
	public function query($shoot_id) {
		$current_user_id = $this->getCurrentUser();
		$comments = $this->comment_dao->query($current_user_id, $shoot_id);
		return json_encode(array('comments'=>$comments));
	}

	public function create() {
		$data = $this->parse_create_request_body();
		$comment = $this->convert_data_to_comment($data);
		$commentObj = $this->comment_dao->create($comment);
	    return json_encode($commentObj);
	}
	
	public function delete($id) {
		$current_user_id = $this->getCurrentUser();
		$this->comment_dao->delete($current_user_id, $id);
	}
	
	private function parse_create_request_body() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('create comment request has to be either POST or PUT.');
		}
		
		$data = json_decode(file_get_contents('php://input'));
		$invalidReason = $this->check_para($data);
		if ($invalidReason) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReason");
		}
		return $data;
	}
	
	private function convert_data_to_comment($data) {
		$currentUser_id = $this->getCurrentUser();
		$comment = new Comment();
		$comment->set_x($data->x);
		$comment->set_y($data->y);
		$comment->set_shoot_id($data->shoot->id);
		$comment->set_user_id($currentUser_id);
		$comment->set_content($data->content);
		return $comment;
	}
	
	private function check_para($data)
	{
		$shoot = $data->shoot;
		if ($shoot == null) {
			return 'Input error, shoot is null';
		}
		
		if ($shoot->id == null) {
			return 'Input error, shoot.id is null';
		}
		
		$content = trim($data->content);
		if ($content == '') {
			return 'Input error, content is null';
		}
		
		$x = $data->x;
		if (!is_float($x) || $x < 0.0 || $x > 1.0) {
			return 'Input error, x is not valid';
		}
		
		$y = $data->y;
		if (!is_float($y) || $y < 0.0 || $y > 1.0) {
			return 'Input error, y is not valid';
		}
		
		return null;		
	}
}
?>