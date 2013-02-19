<?php

require_once 'Config/Lite.php';

$config = new Config_Lite('test.ini');

echo "User: ".$config->get('db', 'user'); // dionysis

echo "<br></br>";

if (true === $config->getBool(null, 'debug', true)) {
    echo $config;
}

?>
