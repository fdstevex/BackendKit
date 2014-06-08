<?php

/*
  Logs a user out, which really just means clearing the authToken cookie.

  Example:
  curl -v http://server/api/logout.php

*/

require_once(dirname(__FILE__) . "/../../../include/kitroot.php");

$redirect = $_REQUEST['redirect'];

BEKUtils::checkCSRFCookie();

if(isset($_COOKIE['BEKAuthToken'])) {
    unset($_COOKIE['BEKAuthToken']);
    setcookie('BEKAuthToken', '', time() - 3600, "/");
    header("Cache-Control: no-cache");
}

if ($redirect) {
    header('Location: ' . $config->webRoot . $redirect);
}

?>
