<?php
/**
* 
*/
class ShootDAO extends BaseDAO
{
	public static $TYPE_HAVE = 0;
	public static $TYPE_WANT = 1;
	
	public function userTagsForShoot($shoot_id, $type) {
		
		$filter = "";
		if($type){
			$filter = "AND user_tag_shoot.type = $type";
		} 
		
		$query = "SELECT shoot.content, shoot.want_count, shoot.like_count, shoot.have_count, shoot.shoot_user_id, shoot.shoot_time, user_tag_shoot.*, tag.tag, tag.want_count as tag_want_count, tag.have_count as tag_have_count, user.user_type, user.username from shoot JOIN user_tag_shoot ON shoot.id = user_tag_shoot.shoot_id AND shoot.id = $shoot_id $filter LEFT JOIN tag ON tag.id = user_tag_shoot.tag_id LEFT JOIN user ON user_tag_shoot.user_id = user.id";
		
		$result = $this->db_conn->query($query);
		$shoots = array();
		if(mysql_num_rows($result)) {
			while($user_tag_shoot = mysql_fetch_assoc($result)) {
				$shoots[] = $this->getStructuredUserTagShoot($user_tag_shoot);	
			}
		}
		return $shoots;
	}
	
	public function queryByTag($tag_id) {
		$query = "SELECT user_tag_shoot.* FROM user_tag_shoot WHERE tag_id = $tag_id";
		$result = $this->db_conn->query($query);
		$user_tag_shoots = array();
		if(mysql_num_rows($result)) {
			while($user_tag_shoot = mysql_fetch_assoc($result)) {
				$user_tag_shoots[] = $this->getStructuredUserTagShoot($user_tag_shoot);	
			}
		}
		return $user_tag_shoots;
	}
	
	private function getStructuredUserTagShoot($user_tag_shoot) {
		
		$shoot = array('id' => $user_tag_shoot['shoot_id'], 
					   'content' => $user_tag_shoot['content'],
				       'want_count' => $user_tag_shoot['want_count'],
				       'like_count' => $user_tag_shoot['like_count'],
					   'have_count' => $user_tag_shoot['have_count'],
				   	   'time' => $user_tag_shoot['shoot_time'],
				       'user' => array('id' => $user_tag_shoot['shoot_user_id']));
		$user = array('id' => $user_tag_shoot['user_id'], 
		              'user_type' => $user_tag_shoot['user_type'],
				      'username' => $user_tag_shoot['username']);
		$tag = array('id' => $user_tag_shoot['tag_id'], 
					 'tag' => $user_tag_shoot['tag'],
				     'have_count' => $user_tag_shoot['tag_have_count'],
				     'want_count' => $user_tag_shoot['tag_want_count']);
		return array('shoot' => $shoot, 
		             'tag' => $tag, 
					 'user' => $user, 
					 'type' => $user_tag_shoot['type'],
					 'time' => $user_tag_shoot['time'],
					 'latitude' => $user_tag_shoot['latitude'],
					 'longitude' => $user_tag_shoot['longitude'],
					 'deleted' => $user_tag_shoot['deleted']
				     );
	}
	
	public function query($currentUser_id, $user_id, $keyword) {
		
		$filter = null;
		$isFeed = false;
		if(!is_null($user_id)) {
			$filter = "where user_tag_shoot.user_id=$user_id";
		}
		if(!is_null($keyword)) {
			if (is_null($filter)) {
				$filter = "where tag.tag like '%$keyword%'";
			} else {
				$filter = $filter . " and tag.tag like '%$keyword%'";
			}
		} 
		if(is_null($filter)) {
			$isFeed = true;
			$filter = "LEFT JOIN follow ON follow.followee_uid = user_tag_shoot.user_id where (follower_uid = $currentUser_id and datediff(now(), user_tag_shoot.time) < 270)";
		} 
		
		$query = "SELECT shoot.content, shoot.want_count, shoot.like_count, shoot.have_count, shoot.shoot_user_id, shoot.shoot_time, tag.tag, tag.want_count as tag_want_count, tag.have_count as tag_have_count, user_tag_shoot.*, user.user_type, user.username FROM shoot LEFT JOIN user_tag_shoot ON shoot.id = user_tag_shoot.shoot_id LEFT JOIN tag on tag.id = user_tag_shoot.tag_id LEFT JOIN user ON user_tag_shoot.user_id = user.id $filter";

		$result = $this->db_conn->query($query);

		$shoots = array();
		if(mysql_num_rows($result)) {
			while($user_tag_shoot = mysql_fetch_assoc($result)) {
				$shootObj = $this->getStructuredUserTagShoot($user_tag_shoot);
				if ($isFeed) {
					$shootObj['is_feed'] = true;
				}
				$shoots[] = $shootObj;
			}
		}

		return $shoots;
	}
	
	public function trends($currentUser_id) {

		$query = "SELECT shoot.content, shoot.want_count, shoot.like_count, shoot.have_count, shoot.shoot_user_id, shoot.shoot_time, user_tag_shoot.*, tag.tag, tag.want_count as tag_want_count, tag.have_count as tag_have_count, user.user_type, user.username, shoot.want_count + like_count as score FROM shoot LEFT JOIN user_tag_shoot ON shoot.id = user_tag_shoot.shoot_id LEFT JOIN user ON user_tag_shoot.user_id = user.id LEFT JOIN tag on user_tag_shoot.tag_id = tag.id group by shoot.id ORDER BY score DESC limit 20;";

		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$shoots = array();
		if(mysql_num_rows($result)) {
			while($user_tag_shoot = mysql_fetch_assoc($result)) {
				$shoots[] = $this->getStructuredUserTagShoot($user_tag_shoot);
			}
		}

		return $shoots;
	}
	
	public function create($shoot)
	{
		$query = 'INSERT INTO shoot (content, shoot_user_id) VALUES (\'' . mysql_real_escape_string($shoot->get_content()) . '\',' . $shoot->get_user_id() . ')';
		$result = $this->db_conn->insert($query);
		
		if (count($shoot->get_tags()) > 0) {
			$tags = $shoot->get_tags();
			foreach ($tags as &$tag) {
				$this->setUserTagShoot($shoot->get_user_id(), $result, $tag, ShootDAO::$TYPE_HAVE, $shoot->get_latitude(), $shoot->get_longitude());
			}
		}
		
		return $result;
	}
	
	/*
	* this function just returns a plain shoot that matches the give id. No extra information will be retrieved
	*/
	public function find_shoot_by_id($id) {
		$condition = "shoot.id = $id";
		$shoots = $this->getShootsWithCondition($condition);
		if(count($shoots) > 0) {
			return $shoots[0];
		} else {
			return null;
		}
	}
	
	public function if_user_like_shoot($user_id, $shoot_id) {
		$query = "SELECT time FROM like_shoot WHERE user_id = $user_id AND shoot_id = $shoot_id";
		$result = $this->db_conn->query($query);
		if(mysql_num_rows($result)) {
			return true;
		} else {
			return false;
		}
	}
	
	public function if_user_want_shoot($user_id, $shoot_id) {
		$query = "SELECT time FROM user_tag_shoot WHERE user_id = $user_id AND shoot_id = $shoot_id AND deleted = 0 AND type = 0";
		$result = $this->db_conn->query($query);
		if(mysql_num_rows($result)) {
			return true;
		} else {
			return false;
		}
	}
	
	public function if_user_have_shoot($user_id, $shoot_id) {
		$query = "SELECT time FROM user_tag_shoot WHERE user_id = $user_id AND shoot_id = $shoot_id AND deleted = 0 AND type = 1";
		$result = $this->db_conn->query($query);
		if(mysql_num_rows($result)) {
			return true;
		} else {
			return false;
		}
	}
	
	private function getShootsWithCondition($condition) {
		$query = "SELECT shoot.*, user.user_type, user.username FROM shoot LEFT JOIN user ON user.id = shoot.shoot_user_id where $condition";
		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$shoots = array();
		if(mysql_num_rows($result)) {
			while($shoot = mysql_fetch_assoc($result)) {
				$shoots[] = $shoot;
			}
		}
		return $shoots;
	}
	
	// public function delete($shoot_id)
	// {
	// 	$query = 'UPDATE shoot SET deleted = 1 WHERE id = ' . $shoot_id;
	// 	$result = $this->db_conn->query($query);
	// }
	
	private function get_tag_id_and_create_if_not_found($tag) {
		$id = $this->get_tag_id($tag);
		if(!$id) {
			try {
				$id = $this->create_tag($tag);
			} catch (Exception $e) {
				$id = $this->get_tag_id($tag);
			}
		} 
		if(!$id) {
			throw new DependencyFailureException("Failed to create tag $tag");
		}	
		return $id;
	}
	
	private function get_tag_id($tag) {
		$query = "select id from tag where tag = '$tag'";
		$result = $this->db_conn->query($query);
		if(mysql_num_rows($result)) {
			while($shoot = mysql_fetch_assoc($result)) {
				return $shoot['id'];
			}
		}
		return null;
	}
	
	private function create_tag($tag) {
		$query = "INSERT INTO tag (tag) values ('$tag')";
		return $this->db_conn->insert($query);
	}
	
	public function setUserTagsShoot($user_id, $shoot_id, $tags, $type, $latitude, $longitude) {
		foreach ($tags as &$tag) {
			$this->setUserTagShoot($user_id, $shoot_id, $tag, $type, $latitude, $longitude);
		}
	}
	
	public function setUserTagShoot($user_id, $shoot_id, $tag, $type, $latitude, $longitude) {
		$tag_id = $this->get_tag_id_and_create_if_not_found($tag);
		$query = "UPDATE shoot SET want_count =  want_count + 1 WHERE id = $shoot_id";
		$this->db_conn->query($query);
		$query = "UPDATE tag SET want_count =  want_count + 1 WHERE id = $tag_id";
		$this->db_conn->query($query);
		try {
			$query = "INSERT INTO user_tag_shoot (shoot_id, user_id, tag_id, type, latitude, longitude) VALUES($shoot_id, $user_id, $tag_id, $type, $latitude, $longitude)";	
			$this->db_conn->query($query);
		} catch (Exception $e) {
			$query = "Update user_tag_shoot set deleted = 0, time = now(), latitude = $latitude, longitude = $longitude where shoot_id = $shoot_id and user_id = $user_id and tag_id = $tag_id and type = $type";	
			$this->db_conn->query($query);
		}
		
	}
	
	public function setUserUntagShoot($user_id, $shoot_id, $tag_id) {
		$query = "UPDATE user_tag_shoot SET deleted = 1 WHERE user_id = $user_id AND tag_id = $tag_id";
		if($shoot_id) {
			$query = $query . " AND shoot_id = $shoot_id";
		}
		$this->db_conn->query($query);
		$affected_rows = mysql_affected_rows();
		if($affected_rows) {
			if($shoot_id) {
				$query = "UPDATE shoot SET want_count =  want_count - $affected_rows WHERE id = $shoot_id";
				$this->db_conn->query($query);
			}
			$query = "UPDATE tag SET want_count =  want_count - $affected_rows WHERE id = $tag_id";
			$this->db_conn->query($query);
		}
	}
	
	public function setUserLikeShoot($user_id, $shoot_id) {
		$query = "INSERT INTO like_shoot (shoot_id, user_id) VALUES($shoot_id,$user_id)";	
		$this->db_conn->query($query);
		$query = "UPDATE shoot SET like_count =  like_count + 1 WHERE id = $shoot_id";
		$this->db_conn->query($query);	
	}
	
	public function setUserUnlikeShoot($user_id, $shoot_id) {
		$query = "DELETE FROM like_shoot WHERE user_id = $user_id AND shoot_id = $shoot_id";
		$this->db_conn->query($query);
		$query = "UPDATE shoot SET like_count =  like_count - 1 WHERE id = $shoot_id";
		$this->db_conn->query($query);
	}
}

?>