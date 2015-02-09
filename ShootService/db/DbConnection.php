<?php

class DbConnection 
{
	public $host = '54.86.238.86';
    
    public $username = 'shoot';

    public $password = 'Shoot@0204';

	public $database = 'shoot';

	private $db_conn;
	
	function __construct() {
		/* connect to the db */
		$this->db_conn = mysql_connect($this->host, $this->username, $this->password);
		if (!$this->db_conn) {
			throw new DependencyFailureException("Failed to connect to database");
		}
		if (!mysql_select_db($this->database, $this->db_conn)) {
			throw new DependencyFailureException("Failed to select database");
		}
		$this->init_connection();
	}
	
	function __destruct() {
		/* disconnect from the db */
        @mysql_close($this->db_conn);
	}

    private function init_connection() {
		$this->db_conn = mysql_connect($this->host, $this->username, $this->password) or die('Cannot connect to the DB');
		mysql_select_db($this->database, $this->db_conn) or die('Cannot select the DB');
	}
	
	public function query($query) {
		$result = mysql_query($query, $this->db_conn);
		if ($result) {
			return $result;
		} else {
			throw new DependencyFailureException("Failed to execute query $query");
		}
	}
	
	public function insert($query) {
		$result = mysql_query($query, $this->db_conn);
		if (!$result)
		{
			throw new DependencyFailureException("Failed to execute insertion $query");
		}
		$id = mysql_insert_id($this->db_conn);
		return $id;
	}
}

?>