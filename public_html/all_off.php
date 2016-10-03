<?php
header("Refresh: 3; url=http://192.168.1.3/");
require_once "PHPTelnet.php";

$telnet = new PHPTelnet();

//Open a Connection
$result = $telnet->Connect('192.168.1.90', '', ''); 	

if ($result == 0) {
	$telnet->DoCommand("0", $result);
	usleep(100);
	$telnet->DoCommand("2", $result);
	usleep(100);
	$telnet->DoCommand("5", $result);
	usleep(100);
	$telnet->DoCommand("8", $result);
	usleep(100);
	$telnet->DoCommand("9", $result);
	

	$telnet->Disconnect(0);
}
?>
Command was sent. You'll be bouced back to the Main page now.
