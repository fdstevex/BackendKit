<?php

require_once(dirname(__FILE__) . "/classes/BEKConfig.php");

$config = new BEKConfig();

if (gethostname() == "stevebookpro") {
    $config->db = new PDO('mysql:host=127.0.0.1;dbname=backendkit;charset=utf8', 'dbuser', 'secret');
    $config->emailFrom = "noreply@falldaysoftware.com";
    $config->webRoot = "http://localhost/~stevex/";
    $config->requireEmailValidation = true;
} else {
    die("No configuration available for current host");
}

$GLOBALS['BEK_config'] = $config;

?>
