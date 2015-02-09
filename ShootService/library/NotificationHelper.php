<?php

class NotificationHelper
{
   	
	public static function sendMessage($deviceToken, $message, $badge_count) {
		
		$passphrase = 'Iloveweed@309';
		
		$ctx = stream_context_create();
		stream_context_set_option($ctx, 'ssl', 'local_cert', 'controller/ck.pem');
		stream_context_set_option($ctx, 'ssl', 'passphrase', $passphrase);

		// Open a connection to the APNS server
		$fp = stream_socket_client(
			'ssl://gateway.sandbox.push.apple.com:2195', $err,
			$errstr, 60, STREAM_CLIENT_CONNECT|STREAM_CLIENT_PERSISTENT, $ctx);

		if (!$fp) {
			error_log("Failed to connect: $err $errstr" . PHP_EOL);
			return;
		}
			

		error_log('Connected to APNS' . PHP_EOL);

		// Create the payload body
		$body['aps'] = array(
			//'alert' => $message,
			'alert' => array(
				'action-loc-key' => 'Open',
				'body' => $message
			),
			'badge' => $badge_count,
			'sound' => 'default'
		);

		// Encode the payload as JSON
		$payload = json_encode($body);

		// Build the binary notification
		// The payload needs to be packed before it can be sent
		$msg = chr(0) . chr(0) . chr(32);
		$msg .= pack('H*', str_replace(' ', '', $deviceToken));
		$msg .= chr(0) . chr(strlen($payload)) . $payload;

		// Send it to the server
		$result = fwrite($fp, $msg, strlen($msg));

		if (!$result)
			error_log('Message ' . $message . ' not delivered to ' . $deviceToken . PHP_EOL);
		else
			error_log('Message successfully delivered to ' . $deviceToken . PHP_EOL);

		// Close the connection to the server
		fclose($fp);
	} 


}
?>
