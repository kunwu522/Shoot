<?php
/**
* run mysql database backup shell script
*/
require_once('/var/www/html/Weeda/WeedaService/library/PHPMailer/PHPMailerAutoload.php');

$username = 'shoot';
$password = 'Shoot@0204';
$database = 'shoot';

$now = date("YmdHis");
$file_name = "db_backup_" . $now . ".sql";
$backup_folder = "/backup/mysql_backup";
$full_path_backup_file = $backup_folder . '/' . $file_name;

if (!file_exists($backup_folder)) {
	mkdir($backup_folder, 0755, true);
}
	
error_log('Start to backup database at ' . date("Y/m/d H:i:s"));
exec("mysqldump --user=$username --password=$password --default-character-set=utf8 $database > $full_path_backup_file");
if (file_exists($full_path_backup_file)) {
	chown($full_path_backup_file, 'ec2-user');
	error_log("Backup successed: " . $full_path_backup_file);
} else {
	error_log('Backup failed.');
	send_mail();
}
error_log('Backup finished at ' . date("Y/m/d H:i:s"));

//Todo: sending email, deleting previous backup

function send_mail()
{
	$mail = new PHPMailer();
	
	//For debug
	// $mail->SMTPDebug = 3;  
	
	$mail->isSMTP();
	$mail->IsHTML(true);
	$mail->Host = "smtp.gmail.com";
	$mail->SMTPAuth = true;
	$mail->Username = 'Weeda.LaVida@gmail.com';
	$mail->Password = 'Iloveweed@309';
	$mail->SMTPSecure = 'tls';                            
	$mail->Port = 587;
	
	$mail->From = 'Weeda.LaVida@gmail.com';
	$mail->FromName = 'Cannablaze.com';
	$mail->addAddress('wukun522@gmail.com', 'tony');
	$mail->addAddress('chaoqing.lv@gmail.com', 'lv');
	$mail->Subject = "Database Backup Failed.";
	$mail->Body = "Database backup failed, please backup database manually";
	
	if (!$mail->send()) {
		error_log('Email sending failed, error ' . $mail->ErrorInfo);
		return false;
	} else {
		error_log('Email has been sent');
		return true;
	}
}

?>