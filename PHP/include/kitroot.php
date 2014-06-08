<?php

/* Configuration - Copy the config-sample.php to config.php, and edit to suit your environment */
require_once(dirname(__FILE__) . "/config.php");

require_once(dirname(__FILE__) . '/lib/password.php');
require_once(dirname(__FILE__) . '/classes/BEKUserDB.php');
require_once(dirname(__FILE__) . '/classes/BEKUtils.php');

$config = $GLOBALS['BEK_config'];
$userdb = new BEKUserDB();

?>
