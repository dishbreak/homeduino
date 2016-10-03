<?php
header("Refresh: 3; url=http://192.168.1.3/devices.html");
require_once "PHPTelnet.php";

$telnet = new PHPTelnet();

//Open a Connection
$result = $telnet->Connect('192.168.1.90', '', ''); 	

$command = $_POST["commandStr"];

if ($result == 0) {
	$telnet->DoCommand("$command", $result);
	$telnet->Disconnect(0);
}
?>
Command was sent. You'll be bouced back to the Main page now.
