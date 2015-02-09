<?php

include './library/ImageHandler.php';

ini_set('display_errors',1);
error_reporting(E_ALL);

define("PASSWORD_DEFAULT", 39);

class UserController extends Controller
{
	protected $message_dao;
    function __construct($model, $controller, $action) 
    {
		parent::__construct($model, $controller, $action);
		$this->message_dao = new MessageDAO();
    }
	
	public function query($id) {
		if (!isset($id)) {
			throw new InvalidRequestException('Input error, id is null.');
		}
		
		$currentUser_id = $this->getCurrentUser();
		
		$user = $this->user_dao->find_by_id($id, $currentUser_id);
		if($user)
			return json_encode(array('user' => $user));
	}
	
	public function registerDevice($device_id) {
		if (!isset($device_id)) {
			throw new InvalidRequestException('Input error, device_id is null.');
		}
		
		$currentUser_id = $this->getCurrentUser();
		$result = $this->user_dao->setUserDevice($currentUser_id, $device_id);
	}
	
	public function unregisterDevice($device_id) {
		if (!isset($device_id)) {
			throw new InvalidRequestException('Input error, device_id is null.');
		}
		
		$currentUser_id = $this->getCurrentUser();
		$result = $this->user_dao->unsetUserDevice($currentUser_id, $device_id);
	}
	
	public function getRecommendedUsers($count) {
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->recommend_users($currentUser_id, $count);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getUsernamesByPrefix($prefix){
		$currentUser_id = $this->getCurrentUser();
		$count = 10;
		$users = $this->user_dao->get_uernames_with_prefix($prefix, $count); 
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
		
	}
	
	public function getFollowingUsers($user, $count){
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->get_following_usernames($user, $currentUser_id, $count);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getFollowers($user, $count){
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->get_follower_usernames($user, $currentUser_id, $count);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getUsersLikeShoot($shoot_id) {
		if (!isset($shoot_id)) {
			throw new InvalidRequestException('Input error, shoot_id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->getUsersLikeShoot($currentUser_id, $shoot_id);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function getUsersWantShoot($shoot_id) {
		if (!isset($shoot_id)) {
			throw new InvalidRequestException('Input error, shoot_id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$users = $this->user_dao->getUsersWantShoot($currentUser_id, $shoot_id);
		if ($users)
			return json_encode(array('users' => $users));
		else
			return json_encode(array('users' => []));
	}
	
	public function follow($id) {
		if (!isset($id)) {
			throw new InvalidRequestException('Input error, id is null.');
		}
		$currentUsername = $this->getCurrentUsername();
		$currentUser_id = $this->getCurrentUser();
		if($this->user_dao->setAFollowB($currentUser_id, $id)) {
			$message = new Message();
			$message->set_message('@' . $currentUsername . ' started following you.');
			$message->set_sender_id($currentUser_id);
			$message->set_receiver_id($id);
			$message->set_time(date('Y-m-d H:i:s'));
			$message->set_related_user_id($id);
			$message->set_type(Message::$MESSAGE_TYPE_NOTIFICATION);
			$notification_message = $message->get_message();
			$this->message_dao->create($message, $notification_message);
			return $this->query($id);
		} else {
			throw new DependencyFailureException('Failed to set current user '. $currentUser_id . ' follow ' . $id);
		}
		
	}
	
	public function unfollow($id) {
		if (!isset($id)) {
			throw new InvalidRequestException('Input error, id is null.');
		}
		$currentUser_id = $this->getCurrentUser();
		$this->user_dao->setAUnfollowB($currentUser_id, $id);
		return $this->query($id);
	}
	
	public function login($parameters) {
		$username = $parameters['username'];
		$password = $parameters['password'];
		$cookie = $parameters['cookie'];
		
		if (!isset($username)) {
			throw new InvalidRequestException('Input para error, username is null');
		}
		
		if (!isset($password)) {
			throw new InvalidRequestException('Input para error, password is null');
		}
		
		if (!isset($cookie)) {
			$cookie = false;
		}
		
		$user = $this->user_dao->find_by_username($username);
		if ($user == null) {
			throw new InvalidRequestException("Did not find user by username:$username");
		}
		
		if ($cookie) {
			if (strcmp($password, $user['password']) !== 0) {
				throw new InvalidRequestException('user/password do not match record.');
			}
		} else {
			if (crypt($password, $user['password']) != $user['password']) {
				throw new InvalidRequestException('user/password do not match record.');
			}
		}
		
		$this->update_cookie($user);
		return json_encode(array("user" => $user));
	}

	public function signout() {		
		try {
			$currentUser_id = $this->getCurrentUser();
			setrawcookie(Controller::$USER_ID_COOKIE_NAME, '', time() - 3600);
			setrawcookie(Controller::$USERNAME_COOKIE_NAME, '', time() - 3600);
			setrawcookie(Controller::$PASSWORD_COOKIE_NAME, '', time() - 3600);
		} catch (DependencyDataMissingException $e) {
			//already log out.
			return;
		}
	}
	
	public function signup() {
		$data = $this->parse_body_request();
		$invalidReasons = $this->check_para($data);
		if (!empty($invalidReasons)) {
			throw new InvalidRequestException("Inputs are not valid due to $invalidReasons");
		}
		$user = $this->convert_data_to_user($data);
		
		if (!$this->check_username($user->get_username())) {
			throw new InvalidRequestException("Username is not valid.");
		}
		
		//Hash password
		$password = $user->get_password();
		$pasword_hash = crypt($password);
		$user->set_password($password_hash);
		
		$result = $this->user_dao->create($user);
		$user->set_id($result);
		$userPropertyMap = array('id'=>$user->get_id(), 'username'=>$user->get_username(), 'password'=>$user->get_password());
		$this->update_cookie($userPropertyMap);	
		
		return json_encode(array('user' => $user));
	}
	
	public function forgotPassword($token_id)
	{
		$error;
		
		$tokenDao = new TokenDAO();
		$token = $tokenDao->find_by_token_id($token_id);
		if (!$token) {
			$error = "Reset password url has expired. Please apply again.";
		}
		if ($token['used']) {
			$error = "Reset password url has expired. Please apply again.";
		}
		
		header('Content-Type: text/html; charset=UTF-8');
		if ($error) {
			$title = "Reset password";
			$message = $error;
			
			ob_start();
			include('./page/notification.php');
			echo ob_get_clean();
		} else {
			$user_id = $token['user_id'];
		
			ob_start();
			include('./page/user/reset.php');
			echo ob_get_clean();
		}
		return;
	}
	
	public function reset()
	{
		if (!isset($_POST['password']) || !isset($_POST['token_id'])) {
			throw new InvalidRequestException("Inputs are not valid");
		}
		
		$token_id = $_POST['token_id'];
		$password = $_POST['password'];
		
		$token_dao = new TokenDAO();
		$token = $token_dao->find_by_token_id($token_id);
		$user_id = $token['user_id'];
		
		$password_hash = crypt($password);
		$this->user_dao->updatePassword($user_id, $password_hash);

		$token_dao->update_used(1, $token_id);
		
		$title = "Reset password";
		$message = "Password has been changed!";		
		header('Content-Type: text/html; charset=UTF-8');
		ob_start();
		include('./page/notification.php');
		echo ob_get_clean();
		return;
	}
	
	private function update_cookie($user){
		setrawcookie(Controller::$USER_ID_COOKIE_NAME, $user['id'], time() + (86400 * 7), '/');
		setrawcookie(Controller::$USERNAME_COOKIE_NAME, $user['username'], time() + (86400 * 7), '/');
		setrawcookie(Controller::$PASSWORD_COOKIE_NAME, $user['password'], time() + (86400 * 7), '/');
	}
	
	public function updateUsername($username) {
		$user_id = $this->getCurrentUser();
		$password = $this->getCurrentUserPassword();
		
		if (!$this->check_username($username)) {
			throw new InvalidRequestException("Username is not valid.");
		}
		
		$this->user_dao->updateUsername($user_id, $username);
		$user = array();
		$user['id'] = $user_id;
		$user['password'] = $password;
		$user['username'] = $username;
		$this->update_cookie($user);
	}
	
	public function updatePassword($user_id, $parameters)
	{
		$cookie_user_id = $this->getCurrentUser();
		$cookie_username = $this->getCurrentUsername();
		$cookie_password = $this->getCurrentUserPassword();
		
		if ($cookie_user_id != $user_id) {
			throw new InvalidRequestException("Inputs are not valid.");
		}
		
		$password = $parameters['password'];
		$current_password = $parameters['current_password'];
		if (!isset($user_id) || !isset($password) || !isset($current_password)) {
			throw new InvalidRequestException("Inputs are not valid.");
		}
		
		if (!$this->check_password($password)) {
			throw new InvalidRequestException("Password is not valid.");
		}
		
		$user = $this->user_dao->find_by_user_id($user_id);
		if (!$user) {
			throw new InvalidRequestException("User is empty.");
		}
		
		if (crypt($current_password, $user->get_password()) != $user->get_password()) {
			throw new InvalidRequestException('Current password is not correct.');
		}
		
		if (strcmp($cookie_password, $user->get_password()) !== 0) {
			throw new InvalidRequestException("password stored is not match.");
		}
		
		$password_hash = crypt($password);
		$this->user_dao->updatePassword($user_id, $password_hash);
		$user = array();
		$user['id'] = $cookie_user_id;
		$user['password'] = $password_hash;
		$user['username'] = $cookie_username;
		$this->update_cookie($user);
	}
	
	public function update() {
		$data = $this->parse_body_request();
		$invalidReasons = $this->check_para($data);
		if (!empty($invalidReasons)) {
			return json_encode(array('errors' => $invalidReasons));
		}
		$user = $this->convert_data_to_user($data);
		$user_id = $this->getCurrentUser();
		if ($user_id != $user->get_id()) {
			throw new InvalidRequestException('Current user id is '. $user_id . ' and it is trying to modify user data for user id ' . $user->get_id() . '.');
		}
		$result = $this->user_dao->update($user);
		return json_encode(array('errors' => array()));
	}
	
	public function upload() {
		$user_id = $this->getCurrentUser();
		
		error_log('Image name: ' . $_FILES['avatar']['name']);
		error_log('Image type: ' . $_FILES['avatar']['type']);
		error_log('Image size: ' . $_FILES['avatar']['size']);
		error_log('Image tmp name: ' . $_FILES['avatar']['tmp_name']);
		
		if (!saveAvatarToServer($_FILES['avatar'], $user_id)) {
			throw new DependencyFailureException('Failed to store avatar.');
		}
		
		$this->user_dao->update_has_avatar($user_id);
	}
	
	public function hasUsername($username) {
		if (!isset($username)) {
			throw new InvalidRequestException('Input error, username is null');
		}
		$exist = $this->user_dao->username_exist($username);
		return json_encode(array('exist' => $exist));
	}
	
	public function hasEmail($email) {
		if (!isset($email)) {
			throw new InvalidRequestException('Input error, email is null');
		}
		$exist = $this->user_dao->email_exist($email);
		return json_encode(array('exist' => $exist));
	}
	
	private function parse_body_request() {
		if ($_SERVER['REQUEST_METHOD'] != 'POST' && $_SERVER['REQUEST_METHOD'] != 'PUT') {
			throw new InvalidRequestException('request has to be either POST or PUT.');
		}
		
		return json_decode(file_get_contents('php://input'));
	}
	
	private function convert_data_to_user($data) {
		$user = new User();
		$user->set_id($data->id);
		$user->set_username($data->username);
		$user->set_password($data->password);
		$user->set_email($data->email);
		$user->set_time($data->time);
		if(!$data->deleted)
			$user->set_deleted(0);
		else
			$user->set_deleted($data->deleted);
		$user->set_has_avatar($data->has_avatar);
		return $user;
	}
	
	private function check_username($username)
	{
		if (!$username) {
			error_log('username is null');
			return false;
		}
		
		$regex = "/[A-Za-z0-9]*/";
		if (preg_match($regex, $username)) {
			if (strlen($username) >= 1 && strlen($username) <= 16) {
				return true;
			}
		}
		return false;
	}
	
	private function check_password($password)
	{
		if (!$password) {
			error_log('password is null');
			return false;
		}
		
		$regex = "((?=.*\\d)(?=.*[A-Z])(?=.*[a-z]).{6,16})";
		if (preg_match($regex, $password)) {
			if (strlen($password) >= 6 && strlen($password) <= 16) {
				return true;
			}
		}
		
		return false;
	}
	
	private function check_para($data) {
		$invalidReasons = array();
		
		$username = trim($data->username);
		if ($username == '') {
			$invalidReasons[] = 'Username can not be empty';
		}
		
		$password = trim($data->password);
		if ($password == '') {
			$invalidReasons[] = 'Password can not be empty';
		}
		
		if (!$this->check_password($password)) {
			$invalidReasons[] = 'Password is not valid.';
		}
		
		$email = trim($data->email);
		if ($email == '') {
			$invalidReasons[] = 'Email can not be empty';
		} else {
			if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
			    $invalidReasons[] = "Email address $email is not valid.";
			}
		}
		
		$time = trim($data->time);
		if ($time == '') {
			$invalidReasons[] = 'Time can not be empty';
		}
		
		return $invalidReasons;
	}
}
?>