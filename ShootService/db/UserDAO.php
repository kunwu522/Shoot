<?php
/**
* 
*/
class UserDAO extends BaseDAO
{
	
	public function create($user) {
		$query = 'INSERT INTO user (username, password, email, time) VALUES (\'' 
				. $user->get_username() . '\',\'' 
				. $user->get_password() . '\',\''
				. $user->get_email() . '\',\'' 
				. $user->get_time() . '\')';
		$result = $this->db_conn->insert($query);
		return $result;
	}
	
	public function updateUsername($user_id, $username) {
		$query = 'UPDATE user SET '
			.'username = \'' . $username. '\''
		    . ' WHERE id = ' . $user_id;
		$this->db_conn->query($query);
	}
	
	public function updatePassword($user_id, $password) {
		$query = 'UPDATE user SET password=\'' . $password . '\' WHERE id=' . $user_id;
		$this->db_conn->query($query); 
	}
		
	
	public function update($user) {
		$query = 'UPDATE user SET '
			.'email = \'' . $user->get_email() . '\', '
			.'username = \'' . $user->get_username() . '\'';
			//user type should be updated separately, should not allow user to modify it
			
	    $query = $query . ' WHERE id = ' . $user->get_id();
		$this->db_conn->query($query);
	}
	
	public function update_has_avatar($user_id, $has_avatar) {
		$query = 'UPDATE user SET has_avatar = ' 
				. ($has_avatar ? '1' : '0') . ' WHERE id = ' . $user_id;

		$this->db_conn->query($query);
	}
	
	public function recommend_users($user_id, $count) {
		$query = "SELECT user.id, user.username as username, user.user_type as user_type, COUNT(fl.follower_uid) AS ifollow, COUNT(flwer.follower_uid) AS follower_count FROM user LEFT JOIN follow AS flwer ON user.id = flwer.followee_uid LEFT JOIN follow AS fl ON user.id = fl.followee_uid AND fl.follower_uid = $user_id GROUP BY user.id HAVING ifollow = 0 AND user.id <> $user_id ORDER BY follower_count DESC";
		if ($count) {
			$query = $query . " LIMIT " . $count;
		}
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($user_id, $user['id']);
				$user['relationship_with_currentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function username_exist($username) {
		$query = 'SELECT COUNT(*) as number FROM user where username=\'' . $username . '\'';
		$result = $this->db_conn->query($query);
		$data = mysql_fetch_assoc($result);
		if ($data['number'] == 0) {
			return false;
		} else {
			return true;
		}
	}
	
	public function email_exist($email) {
		$query = 'SELECT COUNT(*) as number FROM user where email=\'' . $email . '\'';
		$result = $this->db_conn->query($query);
		$data = mysql_fetch_assoc($result);
		if ($data['number'] == 0) {
			return false;
		} else {
			return true;
		}
	}
	
	public function get_uernames_with_prefix($prefix, $count_limit) {		
		$query = 'SELECT * FROM user where username like \'' . $prefix . '%\' limit ' . $count_limit;
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function get_following_usernames($user_id, $currentUser_id, $count_limit) {		
		$query = 'SELECT user.id as id, user.username as username, user.user_type as user_type FROM follow join user on follow.followee_uid = user.id where follow.follower_uid = '. $user_id;
		if ($count_limit) {
			$query = $query . ' LIMIT ' . $count_limit;
		} 
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationship_with_currentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function get_follower_usernames($user_id, $currentUser_id, $count_limit) {		
		$query = 'SELECT user.id as id, user.username as username, user.user_type as user_type FROM follow join user on follow.follower_uid = user.id where follow.followee_uid = '. $user_id;
		if ($count_limit) {
			$query = $query . ' LIMIT ' . $count_limit;
		} 
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationship_with_currentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function find_by_username($username) {

		/* grab the users from the db */
		$query = 'SELECT * FROM user where username = \'' . $username . '\'';

		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			return $user;
		} else {
			return null;
		}
	}
	
	public function find_by_user_id($id) {
		$query = "SELECT * FROM user WHERE id = " . $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user_array = mysql_fetch_assoc($result);
			$user = new User();
			$user->set_id($id);
			$user->set_username($user_array['username']);
			$user->set_password($user_array['password']);
			$user->set_email($user_array['email']);
			$user->set_time($user_array['time']);
			$user->set_deleted($user_array['deleted']);
			$user->set_has_avatar($user_array['has_avatar']);
			return $user;
		} else {
			return null;
		}
	}
	
	public function setUserDevice($user_id, $device_id) {
		$query = "SELECT * FROM device WHERE user_id = $user_id and device_id = '$device_id'";
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			//already exists
		} else {
			$query = "INSERT INTO device VALUES($user_id,'$device_id')";	
			$this->db_conn->insert($query);
		}
	}
	
	public function unsetUserDevice($user_id, $device_id) {
		$query = "DELETE FROM device WHERE user_id = $user_id and device_id = '$device_id'";
		
		$result = $this->db_conn->query($query);
	}
		
	public function find_by_id($id, $currentUser_id) {
		
		$query = "SELECT * FROM user WHERE id = ". $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$user = mysql_fetch_assoc($result);
			$followerCount = $this->getFollowerCount($id);
			$user['follower_count'] = $followerCount;
			$followingCount = $this->getFollowingCount($id);
			$user['following_count'] = $followingCount;
			$haveCount = $this->getHaveCount($id);
			$user['have_count'] = $haveCount;
			$wantCount = $this->getWantCount($id);
			$user['want_count'] = $wantCount;
			$relationship = $this->getRelationship($currentUser_id, $id);
			$user['relationship_with_currentUser'] = $relationship;
			return $user;
		} else {
			return null;
		}
	}
	
	public function getUsersLikeShoot($currentUser_id, $shoot_id) {
		$query = "SELECT user.id as id, user.username as username, user.user_type as user_type FROM like_shoot, user WHERE like_shoot.user_id = user.id AND like_shoot.shoot_id = $shoot_id";
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationship_with_currentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function getUsersWantShoot($currentUser_id, $shoot_id) {
		$query = "SELECT user.id as id, user.username as username, user.user_type as user_type FROM user_tag_shoot LEFT JOIN  user ON user_tag_shoot.user_id = user.id WHERE user_tag_shoot.shoot_id = $shoot_id AND type = 1";
		$result = $this->db_conn->query($query);
		$users = array();
		if (mysql_num_rows($result)) {
			while($user = mysql_fetch_assoc($result)) {
				$relationship = $this->getRelationship($currentUser_id, $user['id']);
				$user['relationship_with_currentUser'] = $relationship;
				$users[] = $user;
			}
		} 
		return $users;
	}
	
	public function getRelationship($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return 0;
		$isAFollowingB = $this->isAFollowingB($userA_id, $userB_id);
		$isBFollowingA = $this->isAFollowingB($userB_id, $userA_id);
		if($isAFollowingB && $isBFollowingA){
			return 4;
		}else if($isAFollowingB){
			return 3;
		}else if($isBFollowingA){
			return 2;
		}else{
			return 1;
		}
	}
	
	public function setAFollowB($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return false;
		$query = "INSERT INTO follow VALUES($userB_id,$userA_id)";	
		$this->db_conn->query($query);
		return true;
	}
	
	public function setAUnfollowB($userA_id, $userB_id) {
		if($userA_id == $userB_id)
			return false;
		$query = "DELETE FROM follow WHERE followee_uid = $userB_id AND follower_uid = $userA_id";	
		$this->db_conn->query($query);
		return true;
	}
	
	
	private function isAFollowingB($userA_id, $userB_id) {
		$query = "SELECT count(*) as count FROM follow WHERE followee_uid = $userB_id AND follower_uid = $userA_id";	
		$result = $this->db_conn->query($query);
		$isAFollowingB = false;
		$val = mysql_fetch_assoc($result)['count'];
		if ($val > 0) {
			$isAFollowingB = true;
		}
		return $isAFollowingB;
	}
	
	private function getFollowerCount($id) {
		
		$query = "SELECT count(*) as count FROM follow WHERE followee_uid = ". $id;
		
		$result = $this->db_conn->query($query);
		
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	private function getFollowingCount($id) {
		
		$query = "SELECT count(*) as count FROM follow WHERE follower_uid = ". $id;
		
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	
	private function getHaveCount($id) {
		
		$query = "SELECT count(DISTINCT(tag_id)) as count FROM user_tag_shoot WHERE deleted = 0 AND type = 0 AND user_id = ". $id;
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
	
	private function getWantCount($id) {
		
		$query = "SELECT count(DISTINCT(tag_id)) as count FROM user_tag_shoot WHERE deleted = 0 AND type = 1 AND user_id = ". $id;
		$result = $this->db_conn->query($query);
		if (mysql_num_rows($result)) {
			$val = mysql_fetch_assoc($result);
			return $val['count'];
		} else {
			return 0;
		}
	}
}

?>