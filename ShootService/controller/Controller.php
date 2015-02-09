<?php

class Controller
{
    protected $_model;
	protected $_controller;
	protected $_action;
	protected $_template;
	
	protected $model;
	
	protected $user_dao;
	
	public static $USER_ID_COOKIE_NAME = 'user_id';
    public static $USERNAME_COOKIE_NAME = 'username';
    public static $PASSWORD_COOKIE_NAME = 'password';

	function __construct($model, $controller, $action) {
		$this->_controller = $controller;
	    $this->_action = $action;
	    $this->_model = ucwords($model);
		$this->user_dao = new UserDAO();			
	    // $this->$model = new $model;
	    // $this->_template = new Template($controller, $action);
	}
	
	protected function getCurrentUser(){
		$currentUser_id = $_COOKIE[Controller::$USER_ID_COOKIE_NAME];
		if (!isset($currentUser_id)) {
			throw new DependencyDataMissingException('current user is not set');
		}
		return $currentUser_id;
	}
	
		
	protected function getCurrentUsername(){
		$currentUsername= $_COOKIE[Controller::$USERNAME_COOKIE_NAME];
		if (!isset($currentUsername)) {
			throw new DependencyDataMissingException('current username is not set');
		}
		return $currentUsername;
	}
	
	protected function getCurrentUserPassword(){
		$currentUserPassword= $_COOKIE[Controller::$PASSWORD_COOKIE_NAME];
		if (!isset($currentUserPassword)) {
			throw new DependencyDataMissingException('current password is not set');
		}
		return $currentUserPassword;
	}
	
	// function set($name,$value) {
	//         $this->_template->set($name,$value);
	// }
	// 
	// function __destruct() {
	// 	$this->_template->render();
	// }
	// 
	// function load($modelArray=''){
	//     if(empty($modelArray)){
	//         return false;
	//     }else if(is_array($modelArray)){
	//     	foreach($modelArray as $model){
	//             $this->$model = new $model;
	//         }
	//     }else{
	//         $this->$modelArray = new $modelArray;
	//     }
	// }
}
?>