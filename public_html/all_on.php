<?php
header("Refresh: 1; url=http://192.168.1.3/");
require_once "PHPTelnet.php";

$telnet = new PHPTelnet();

//Open a Connection
$result = $telnet->Connect('192.168.1.90', '', ''); 	

if ($result == 0) {
	$telnet->DoCommand("0", $result);
	usleep(100);
	$telnet->DoCommand("1", $result);
	usleep(50);
	$telnet->DoCommand("1", $result);
	usleep(100);
	$telnet->DoCommand("2", $result);
	usleep(100);
	$telnet->DoCommand("4", $result);
	usleep(100);
	$telnet->DoCommand("6", $result);
	usleep(100);
	$telnet->DoCommand("7", $result);
	

	$telnet->Disconnect(0);
}
?>
Command was sent. You'll be bounced back to the Main page now.
