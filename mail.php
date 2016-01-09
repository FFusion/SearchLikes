
<?php
$_POST = json_decode(file_get_contents('php://input'), true);
$name=$_POST[fio];
$message=$_POST[wish];
$from=$_POST[email];

$to="shabarinalex@gmail.com";
$subject="Mail from ".$name ." ".$from;
mail($to,$subject,$message,"$from");
?>