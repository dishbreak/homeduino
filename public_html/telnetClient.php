<?php
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
<h1>Results</h1><br>
<h2>Command Sent</h2><br>
<?php echo $command; ?><br>
<h2>Arduino Response</h2><br>
<?php echo $result?>

