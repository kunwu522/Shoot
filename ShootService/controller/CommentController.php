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
}
?>