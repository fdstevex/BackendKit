<?php

require_once(dirname(__FILE__) . "/../../../include/kitroot.php");

$method = $_SERVER['REQUEST_METHOD'];
$redirect = $_REQUEST['redirect'];
$response = array('success' => false);

if ($method == 'GET') {
    $vt = $_GET['vt'];
    if (isset($vt)) {
        if (!$userdb->checkValidationToken($vt)) {
            header('Location: ' . $config->webRoot . $config->forgotPasswordTokenInvalidPage);
            exit;
        } else {
            setcookie("BEKVerificationToken", $vt, 0, "/");
            header('Location: ' . $config->webRoot . $config->forgotPasswordFormPage);
            exit;
        }
    }
} else if ($method == 'POST') {
    $vt = $_POST['vt'];
    $authToken = $_REQUEST['BEKAuthToken'];
    $email = $_POST['email'];
    $password = $_POST['password'];
    $newpassword = $_POST['newpassword'];

    if (!empty($email)) {
        // Send the password reset message
        $response = $userdb->sendForgotPasswordEmail($email);
        if ($redirect) {
            if ($response['success']) {
                header('HTTP/1.1 200 OK');
                header('Location: ' . $config->webRoot . $redirect);
                exit;
            } else {
                echo 'error sending password reset email';
                header('HTTP/1.1 500 Internal Error');
                exit;
            }
        } else {
            $response = array_filter(array('success'=>$response['success'], 'reason' => $response['reason'], 'reasonCode' => $response['reasonCode']));
        }
    } else if ((isset($vt) || isset($authToken)) && isset($newpassword)) {
        if (!empty($vt)) {
            // Password reset (user forgot password, so authentication is by the
            // verification token that was emailed to them).
            $response = $userdb->resetPassword($vt, $newpassword);
        } else {
            // Change password (user is logged in, so authentication is by the
            // standard authentication token).
            BEKUtils::checkCSRFCookie();
            $response = $userdb->changePassword($authToken, $password, $newpassword);
        }

        // Reset and change password use the same response handling.

        if ($response['success']) {
            // Password changed - redirect
            header('HTTP/1.1 200 OK');
            if ($redirect) {
                header('Location: ' . $config->webRoot . $redirect);
                exit;
            } else {
                echo json_encode(array('success' => true));
                exit;
            }
        } else {
            header('HTTP/1.1 200 OK');
            $error_redirect = $_POST['errorredirect'];
            if ($error_redirect) {
                header('Location: ' . $config->webRoot . $error_redirect);
                exit;
            } else {
                echo json_encode(array_filter(array('reason' => $response['reason'], 'reasonCode' => $response['reasonCode'])));
                exit;
            }
        }
    }
}

echo json_encode($response);

?>

