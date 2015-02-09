<?php

include './library/NotificationHelper.php';
/**
* 
*/
class MessageDAO extends BaseDAO
{
	public function create($message, $notification_message) {
		$query = 'INSERT INTO message (sender_id, receiver_id, message, type, related_shoot_id, related_user_id, image_metadata, time) VALUES ('
			    . $message->get_sender_id() . ',' 
			    . $message->get_receiver_id() . ',' 
				. ($message->get_message() == NULL ? 'NULL' : ('\'' . mysql_real_escape_string($message->get_message()) . '\'')) . ',\'' 
				. $message->get_type() . '\','
				. ($message->get_related_shoot_id() == NULL ? 'NULL' : $message->get_related_shoot_id()) . ','  
				. ($message->get_related_user_id() == NULL ? 'NULL' : $message->get_related_user_id()) . ',\''  
				. ($message->get_image_metadata() == NULL ? 'NULL' : $message->get_image_metadata()) . '\', now())';
		$id = $this->db_conn->insert($query);
		
		$unread_message_count_query = 'select count(*) as count from message where is_read = 0 and receiver_id = ' . $message->get_receiver_id();
		$unread_message_count_query_result = $this->db_conn->query($unread_message_count_query);
		if(mysql_num_rows($unread_message_count_query_result)) {
			while($count_result = mysql_fetch_assoc($unread_message_count_query_result)) {
				error_log($count_result['count']);
				$this->sendNotificationToUser($message->get_receiver_id(), $notification_message, intval($count_result['count']));
				break;
			}
		}
		return $id;
	}
	
	/**
	* return messages that 'invole' given user and are unread or less than one day old
	*/
	public function query($user_id, $message_id) {
		$query = 'SELECT message.id as id, message.image_metadata as image_metadata, sender.username as sender_username, receiver.username as receiver_username, sender.user_type as sender_user_type, receiver.user_type as receiver_user_type, sender_id, receiver_id, message, message.time as time, message.deleted as deleted, type, related_shoot_id, is_read FROM message LEFT JOIN user as sender on message.sender_id = sender.id LEFT JOIN user as receiver on message.receiver_id = receiver.id WHERE (is_read = false or message.time > timestampadd(hour, -24, now())) and (receiver_id = ' . $user_id . ' or sender_id = ' . $user_id . ')';
		if ($message_id) {
			$query = $query . ' and message.id = ' . $message_id;
		}
		$result = $this->db_conn->query($query);

		$messages = array();
		if(mysql_num_rows($result)) {
			while($message = mysql_fetch_assoc($result)) {
				// no need to send notification back to sender
				if ($message['type'] == Message::$MESSAGE_TYPE_NOTIFICATION && $user_id == $message['sender_id']) {
					continue;
				}
					
				if ($user_id == $message['receiver_id']) {
					$participant_id = $message['sender_id'];
					$participant_type = $message['sender_user_type'];
					$participant_username = $message['sender_username'];
				} else {
					$participant_id = $message['receiver_id'];
					$participant_type = $message['receiver_user_type'];
					$participant_username = $message['receiver_username'];
				}
				$image_metadata = null;
				if ($message['image_metadata']) {
					$image_metadata = json_decode($message['image_metadata']);
				}
				$is_read = $user_id == $message['sender_id'] ? 1 : $message['is_read'];
				$messageObj = array('id' => $message['id'], 'sender_id' => $message['sender_id'], 'image_metadata' => $image_metadata, 'message' => $message['message'], 'time' => $message['time'], 'deleted' => $message['deleted'], 'type' => $message['type'], 'related_shoot_id' => $message['related_shoot_id'], 'is_read' => $is_read, 'participant_id' => $participant_id, 'participant_type' => $participant_type, 'participant_username' => $participant_username);
				$messages[] = $messageObj;
			}
		}
		return $messages;
	}
	
	public function delete($message_id) {		
		$query = "delete from message where id = $message_id";
		$result = $this->db_conn->query($query);
	}
	
	/**
	* requiring receiver_id to avoid setting wrong message to be read
	*/
	public function mark_message_as_read($receiver_id, $message_id) {
		$query = "UPDATE message SET is_read = true WHERE id = $message_id AND receiver_id = $receiver_id";
		return $this->db_conn->query($query);
	}
	
	protected function sendNotificationToUser($user_id, $message, $badge_count) {
		$devices = $this->getUserDevicesByUserId($user_id);
		foreach ($devices as &$device) {
		    NotificationHelper::sendMessage($device['device_id'], $message, $badge_count);
		}
	}
	
	public function getUserDevicesByUserId($user_id) {		
		$query = "SELECT device_id FROM device WHERE user_id = $user_id";
		$result = $this->db_conn->query($query);
		$devices = array();
		if (mysql_num_rows($result)) {
			while($device = mysql_fetch_assoc($result)) {
				$devices[] = $device;
			}
		} 
		return $devices;
	}
	
	public function getUserDevicesByUsername($username) {		
		$query = "SELECT device.device_id as device_id FROM device, user WHERE device.user_id = user.id AND user.username = '$username'";
		$result = $this->db_conn->query($query);
		$devices = array();
		if (mysql_num_rows($result)) {
			while($device = mysql_fetch_assoc($result)) {
				$devices[] = $device;
			}
		} 
		return $devices;
	}
}

?>