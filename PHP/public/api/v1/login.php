<?php

require_once(dirname(__FILE__) . "/../../../include/kitroot.php");

$method = $_SERVER['REQUEST_METHOD'];
$redirect = $_POST['redirect'];

if ($method == 'GET') {
    // GET is used for email address verification
    $verify = $_REQUEST['vt'];
    $response = $userdb->verifyEmailAddress($verify);
    // Redirect upon click on the validation link
    $authToken = $response['authToken'];
    if ($authToken) {
        setcookie("BEKAuthToken", $authToken, $config->authCookieLifetime, "/");
        header('Location: ' . $config->webRoot . $config->emailValidationSuccessPage);
    } else {
        header('Location: ' . $config->webRoot . $config->emailValidationFailurePage);
    }
} else if ($method == 'POST') {
    $email = $_POST['email'];
    $password = $_POST['password'];

    // Log in
    $response = $userdb->login($email, $password);

    $authToken = $response['authToken'];
    if ($authToken) {
        setcookie("BEKAuthToken", $authToken, $config->authCookieLifetime, "/");
    } else {
        // Error is passed back as a session cookie
        setcookie("BEKLastReason", $response['reason'], 0, "/");
        setcookie("BEKLastReasonCode", $response['reasonCode'], 0, "/");
    }

    if ($redirect) {
        header('Location: ' . $config->webRoot . $redirect);
    } else {
        if ($response['success']) {
            if ($response['extra']) {
                echo json_encode(array('authToken' => $response['authToken'],
                                       'extra' => $response['extra']));
            } else {
                echo json_encode(array('authToken' => $response['authToken']));
            }
        } else {
            echo json_encode(array('success' => false,
                                   'reasonCode' => $response['reasonCode'],
                                   'reason' => $response['reason']));
        }
    }
} else if ($method == 'PUT') {
    parse_str(file_get_contents("php://input"), $put_vars);
    BEKUtils::checkCSRFCookie($put_vars);

    $authToken = $put_vars['authToken'];
    $extra = $put_vars['extra'];

    if (!$userdb->updateExtra($authToken, $extra)) {
        http_response_code(403);
    }
}

?>
