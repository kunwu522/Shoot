<?php

// ini_set('display_errors',1);
// error_reporting(E_ALL);

include './library/ImageHandler.php';

class ImageController extends Controller
{
	private $UPLOAD_BASE_PATH = './upload/';
	
	public function upload($shoot_id)
	{
		$user_id = $this->getCurrentUser();
		
		error_log('Image name: ' . $_FILES['image']['name']);
		error_log('Image type: ' . $_FILES['image']['type']);
		error_log('Image size: ' . $_FILES['image']['size']);
		error_log('Image tmp name: ' . $_FILES['image']['tmp_name']);

		if (!saveImageForShootToServer($_FILES['image'], $user_id, $weed_id)) {
			throw new DependencyFailureException('Failed to upload image for shoot ' . $shoot_id);
		}
	}
	
	public function query($image_id, $parameters)
	{
		if (!isset($image_id)) {
			throw new InvalidRequestException('Input error, $image_id is null');
		}
		
		$image_quality = $parameters['quality'];
		if (!isset($image_quality)) {
			$image_quality = 25;
		}
		
		$image = $this->getImageForServer($image_id);
		if (!image) {
			error_log('Image not exist. image url: ' . $image_id);
			throw new InvalidRequestException('Image not exist');
		}
		
		$type = strstr($image_id, '_', true);
		if ($type == "avatar" || $type == "bg") {
			header('Cache-Control: no-transform, max-age=86400');
		}
		header('Content-Type: image/jpeg');
		ob_start();
		imagejpeg($image, null, $image_quality);
		$size = ob_get_length();
		header('Content-Length: '.$size);
		ob_end_flush();
		imagedestroy($image);
	}

	private function getImageForServer($image_url)
	{	
		$url_arr = array();
		$url_arr = explode('_', $image_url);
		
		if (empty($url_arr)) {
			error_log('Invalid url, url:' . $image_url);
			return null;
		}
		
		$filename = null;
		$type = array_shift($url_arr);
		if ($type == 'shoot') {
			$user_id = array_shift($url_arr);
			$shoot_id = array_shift($url_arr);
			$quality = array_shift($url_arr);
			if (!$user_id || !$shoot_id) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_shoot_image_filename($user_id, $shoot_id);
		} else if ($type == 'message') {
			$user_id = array_shift($url_arr);
			$message_id = array_shift($url_arr);
			$quality = array_shift($url_arr);
			if (!$user_id || !$message_id) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_message_image_filename($user_id, $message_id);
		} else if ($type == 'avatar') {
			$user_id = array_shift($url_arr);
			if (!user_id) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_avatar_filename($user_id);
		} elseif ($type == 'bg') {
			$user_id = array_shift($url_arr);
			if (!user_id) {
				error_log('Invalid url, url: ' . $image_url);
				return null;
			}
			$filename = $this->get_bg_filename($user_id);
		} else {
			error_log('Invalid image type, type: ' . $type);
			return null;
		}
		error_log('Image name: ' . $filename);
		$image = imagecreatefromjpeg($filename);
		if (!$image) {
			error_log('Get Image failed - Loading error.');
			return null;
		}
		return $image;
	}
	
	private function get_shoot_image_filename($user_id, $shoot_id)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/shoot/' . $shoot_id . '/1.jpeg';
	}
	
	private function get_message_image_filename($user_id, $message_id)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/message/' . $message_id . '.jpeg';
	}
	
	private function get_avatar_filename($user_id)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/avatar/avatar.jpeg';
	}
	
	private function get_bg_filename($user_id)
	{
		return $this->UPLOAD_BASE_PATH . $user_id . '/bg/bg.jpeg';
	}
}
?>