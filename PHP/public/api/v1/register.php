<?php

/*
  Register is how a user establishes an account. Accounts are identified by an
  email address.
   
  Example:
  curl -F "email=foo@bar.com" -F "password=secret" http://server/api/register.php
  
*/

require_once(dirname(__FILE__) . "/../../../include/kitroot.php");

$email = $_POST['email'];
$password = $_POST['password'];
$extra = $_POST['extra'];
$redirect = $_POST['redirect'];

$response = $userdb->register($email, $password, $extra);

if ($response['success']) {
    if ($response['authToken']) {
        $responseJSON = array('authToken' => $response['authToken']);
    } else {
        if ($config->requireEmailValidation) {
            $response = $userdb->sendValidationEmailForAccount($response['userid']);
        if ($response['success']) {
                $responseJSON = array('success' => true, 'reasonCode' => 102,
                    'reason' => 'validation email sent');
            } else {
                $responseJSON = $response;
            }
        } else {
            $responseJSON = array('success' => false, 'reasonCode' => 501,
                'reason' => 'internal error');
        }
    }
} else {
    $responseJSON = array('success' => false,
                           'reasonCode' => $response['reasonCode'],
                           'reason' => $response['reason']);
}

if ($response['authToken']) {
    setcookie("BEKAuthToken", $response['authToken'], $config->authCookieLifetime, "/");
} else {
    // Error is passed back as a session cookie
    setcookie("BEKLastReason", $responseJSON['reason'], 0, "/");
    setcookie("BEKLastReasonCode", $responseJSON['reasonCode'], 0, "/");
}

if ($redirect) {
    header('Location: ' . $config->webRoot . $redirect);
} else {
    echo json_encode($responseJSON);
}

?>
