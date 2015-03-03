<?php

 	const UPLOAD_BASE_PATH = './upload/';
	
	// ini_set('display_errors',1);
	// error_reporting(E_ALL);

	/**
	 * Save Avatar file to server.
	 *
	 * @param $file <p>
	 * $_FILES['avatar']
	 * </p>
	 * @param $user_id <p>
	 * The current user id.
	 * </p>
	 * 
	 * @return bool true on success.
	 *
	 */
	function saveAvatarToServer($image, $user_id) {
		$destinationPath = get_user_profile_filepath($user_id);
		return saveImageUnderPath($image, $destinationPath);
	}
	
	/**
	 * Save Weeds image to server
	 * 
	 * @param $tmp_image <p>
	 * The tmp file of upload file ($_FILES['file']['tmp_name']).
	 * </p>
	 * @param $user_id <p>
	 * The current user id.
	 * </p>
	 * @param $shoot_id <p>
	 * The id of shoot which contained this image.
	 * </p>
	 * 
	 * @return bool, true on success.
	 * 
	 */
	
	function saveImageForShootToServer($image, $user_id, $shoot_id) {
		$destinationPath = get_shoot_image_filepath($user_id, $shoot_id);
		return saveImageUnderPath($image, $destinationPath);
	}
	
	function saveImageForMessageToServer($image, $user_id, $message_id) {
		$destinationPath = get_message_image_filepath($user_id, $message_id);
		return saveImageUnderPath($image, $destinationPath);
	}
	
    function saveImageUnderPath($image, $folder_path) {
		error_log('save image...');
		$error = 'Error uploading file';
		switch( $image['error'] ) {
			case UPLOAD_ERR_OK:
				$error = false;;
				break;
			case UPLOAD_ERR_INI_SIZE:
			case UPLOAD_ERR_FORM_SIZE:
				$error .= ' - file too large (limit of '.get_max_upload().' bytes).';
				break;
			case UPLOAD_ERR_PARTIAL:
				$error .= ' - file upload was not completed.';
				break;
			case UPLOAD_ERR_NO_FILE:
				$error .= ' - zero-length file uploaded.';
				break;
			case UPLOAD_ERR_NO_TMP_DIR:
				$error .= ' - tmp file no exist.';
				break;
			case UPLOAD_ERR_CANT_WRITE:
				$error .= ' - file cannot write.';
				break;
			default:
				$error .= ' - internal error #'.$image['error'];
				break;
		}
		
		
		if( !$error ) {
			if( !is_uploaded_file($image['tmp_name']) ) {
				$error = 'Error uploading file - unknown error.';
				error_log($error);
				return false;
			} else {
				if (!file_exists($folder_path)) {
					if (!mkdir($folder_path, 0777, true)) {
						$error = error_get_last();
    					error_log($error['message']);
						return false;
					}
					error_log('create directory: ' . $folder_path);
				}
				
				if (move_uploaded_file ( $image['tmp_name'], $folder_path . '/' . $image['name'])){
					error_log ( "Stored in: " . $folder_path . $image["name"] );
					return true;
				} else {
					$error = 'Error uploading file - move file failed.';
					error_log($error);
					return false;
				}
			}
		} else {
			error_log('Upload file failed: ' . $error);
			return false;
		}
	}
	
	function delete_shoot_image_dir($user_id, $shoot_id)
	{
		$deletePath = get_shoot_image_filepath($user_id, $shoot_id);
		remove_dir($deletePath);
		error_log('Deleting path: ' . $deletePath . ' successful.');
	}
	
	function get_user_profile_filepath($user_id) {
		return UPLOAD_BASE_PATH . $user_id . '/avatar/';
	}
	
	function get_user_profile_filename($user_id) {
		return UPLOAD_BASE_PATH . $user_id . '/avatar/avatar.jpeg';
	}
	
	function get_shoot_image_filepath($user_id, $shoot_id) {
		return UPLOAD_BASE_PATH . $user_id . '/shoot/' . $weed_id . '/';
	}
	
	function get_message_image_filepath($user_id, $message_id) {
		return UPLOAD_BASE_PATH . $user_id . '/message/';
	}
	
	function remove_dir($path)
	{
		foreach(glob("{$path}/*") as $file) {
		    if(is_dir($file)) { 
		        remove_dir($file);
		    } else {
		        unlink($file);
		    }
		}
		rmdir($path);
	}

?>