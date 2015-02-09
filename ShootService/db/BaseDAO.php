<?php
/**
* 
*/
class BaseDAO
{
	protected $db_conn;
	
	function __construct()
	{
		//conntect to db
		$this->db_conn = new DbConnection();
	}
}

?>