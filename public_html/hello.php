<?php 
class HttpRequest;
header('Refresh:1; url=http://192.168.1.3'); 
$r = new HttpRequest('http://192.168.1.90'. HttpRequest::METH_POST);
$r->setRawPostData('Hey, does this work?');
$r->send();
?>
<h1>"Hello world!"<br></h1>
You will be redirected back now. Bye!<br>

