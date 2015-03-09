<?php
/**
* 
*/
class CommentDAO extends BaseDAO
{
	public function query($currentUser_id, $shoot_id) {
		$query = "SELECT comment.*, like_comment.user_id as if_cur_user_like_it from comment LEFT JOIN like_comment on comment.id = like_comment.comment_id and like_comment.user_id = $currentUser_id where shoot_id = $shoot_id";
		error_log($query);
		$result = $this->db_conn->query($query);

		/* create one master array of the records */
		$comments = array();
		if(mysql_num_rows($result)) {
			while($comment = mysql_fetch_assoc($result)) {
				$comments[] = $this->getStructuredComment($comment, $currentUser_id);
			}
		}
		return $comments;
	}
	
	private function getStructuredComment($comment, $currentUser_id) {
		
		$shoot = array('id' => $comment['shoot_id']);
		$user = array('id' => $comment['user_id']);
		return array('shoot' => $shoot, 
		             'user' => $user, 
					 'id' => $comment['id'], 
		             'content' => $comment['content'],
					 'x' => $comment['x'],
					 'y' => $comment['y'],
					 'time' => $comment['time'],
					 'like_count' => $comment['like_count'],
					 'latitude' => $comment['latitude'],
					 'longitude' => $comment['longitude'],
					 'if_cur_user_like_it' => $comment['if_cur_user_like_it'] == $currentUser_id,
					 'deleted' => $comment['deleted']
				     );
	}
	
	public function setUserLikeComment($user_id, $comment_id) {
		$query = "INSERT INTO like_comment (comment_id, user_id) VALUES($comment_id,$user_id)";	
		$this->db_conn->query($query);
		$query = "UPDATE comment SET like_count =  like_count + 1 WHERE id = $comment_id";
		$this->db_conn->query($query);	
	}
	
	public function setUserUnlikeComment($user_id, $comment_id) {
		$query = "DELETE FROM like_comment WHERE user_id = $user_id AND comment_id = $comment_id";
		$this->db_conn->query($query);
		$query = "UPDATE comment SET like_count =  like_count - 1 WHERE id = $comment_id";
		$this->db_conn->query($query);
	}
}

?>