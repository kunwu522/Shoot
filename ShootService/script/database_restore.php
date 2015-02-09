<?php

$username = 'shoot';
$password = 'Shoot@0204';
$database = 'shoot';

$backup_folder_path = '/backup/mysql_backup';

if (file_exists($bakcup_folder_path)) {
	error_log('/backup/mysql_backup directory is not exist, please check this folder.');
	exit();
}

$bakcup_file = $argv[1];
if (!isset($file)) {
	$backup_files = scandir($backup_folder_path);
	$last_file = null;
	foreach ($backup_files as $file) {
		if (!$last_file) {
			$last_file = $file;
			continue;
		} 
		
		$filetime = filemtime($file);
		$last_filetime = filemtime($last_file);
		if ($filetime > $last_filetime) {
			$last_file = $file;
		}
	}
	$backup_file = $last_file;
}

error_log('Start to restore database, bakcup file: ' . $backup_file);
exec("mysql --verbose --user=$username --password=$password $database < $backup_file");
error_log('Restore finished.');
?>