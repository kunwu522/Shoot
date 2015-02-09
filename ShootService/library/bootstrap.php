<?php
// Simple bootstrap file PHP 5 (with no template engine)
// stop error reporting for curious eyes, should be set to E_ALL when debugging
error_reporting(0);
// name of folder that application class files reside in
define('CONTROLLER', 'controller');
// name of folder that model class files reside in
define('MODEL', 'model');
// name of folder that db class in
define('DB', 'db');
// name of folder that exception class in
define('EXCEPTION', 'exception');
// application absolute path to source files (should reside on a folder one level behind the public one)
define('CONTROLLERDIR', @realpath(dirname(__FILE__).'/../'.CONTROLLER).'/');
define('MODELDIR', @realpath(dirname(__FILE__).'/../'.MODEL).'/');
define('DBDIR', @realpath(dirname(__FILE__).'/../'.DB).'/');
define('EXCEPTIONDIR', @realpath(dirname(__FILE__).'/../'.EXCEPTION).'/');

// function to autoload classes (getting rid of include() calls)
function wl_autoload($class)
{
	// error_log('Init class '. $class, 3, "/var/log/apache2/weeda_warning_log");
	
	try {
		$file = CONTROLLERDIR.$class.'.php';
		if (file_exists($file)) {
			// error_log("require: ".$file, 3, "/var/log/apache2/weeda_warning_log");
			require($file);
			return;
		}

		$model_file = MODELDIR.$class.'.php';
		if (file_exists($model_file)) {
			// error_log("require: ".$model_file, 3, "/var/log/apache2/weeda_warning_log");
			require($model_file);
			return;
		}

		$db_file = DBDIR.$class.'.php';
		if (file_exists($db_file)) {
			// error_log("require: ".$db_file, 3, "/var/log/apache2/weeda_warning_log");
			require($db_file);
			return;
		}
		
		$exception_file = EXCEPTIONDIR.$class.'.php';
		if (file_exists($exception_file)) {
			// error_log("require: ".$exception_file, 3, "/var/log/apache2/weeda_warning_log");
			require($exception_file);
			return;
		}
		
	} catch (Exception $e) {
		error_log($e->getMessage());
	}
	
	
	error_log('Requested module \''.$class.'\' is missing. Execution stopped.');
}

spl_autoload_register('wl_autoload');
require_once('./library/PHPMailer/PHPMailerAutoload.php');


// the router code, breaks request uri to parts and retrieves the specific class, method and arguments
// $route = '';
// $class = '';
// $method = '';
// $args = null;
// $cmd_path = BASEDIR;
// $fullpath = '';
// $file = '';
// if (empty($_GET['route'])) $route = 'index'; else $route = $_GET['route'];
// $route = trim($route, '/\\');
// $parts = explode('/', $route);
// foreach($parts as $part)
// {
// 	$part = str_replace('-', '_', $part);
// 	$fullpath .= $cmd_path.$part;
// 	if (is_dir($fullpath))
// 	{
// 		$cmd_path .= $part.'/';
// 		array_shift($parts);
// 		continue;
// 	}
// 	if (is_file($fullpath.'.php'))
// 	{
// 		$class = $part;
// 		array_shift($parts);
// 		break;
// 	}
// }
// if (empty($class)) $class = 'index';
// $action = array_shift($parts);
// $action = str_replace('-', '_', $action);
// if (empty($action)) $action = 'index';
// $file = $cmd_path.$class.'.php';
// $args = $parts;
// // now that we have the parts, let's run a few more test and then execute the function in the class file
// if (is_readable($file) == false)
// {
// 	echo 'Requested module \''.$class.'\' is missing. Execution stopped.';
// 	exit();
// }
// // load the requested file
// $class = new $class();
// if (is_callable(array($class, $action)) == false)
// {
// 	// function not found in controller, set it as index and send it to args
// 	array_unshift($args, $action);
// 	$action = 'index';
// }
// // Run action
// $class->$action($args);
?>