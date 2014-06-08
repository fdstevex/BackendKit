<?php

class BEKUserDB
{
    var $config;

	function __construct() {
        $this->config = $GLOBALS['BEK_config'];
	}

    public function deleteAccount($email) {
        $sql = 'DELETE FROM bek_users WHERE email = :email';
        $stmt = $this->config->db->prepare($sql);
        $stmt->bindParam(':email', $email);
        return $stmt->execute();
    }

	/*
	  Check for existence of an account.  Returns boolean.
	 */
	
	public function accountExists($email) {
		$sql = 'SELECT COUNT(*) from bek_users WHERE email_address = :email_address';
		$stmt = $this->config->db->prepare($sql);
		$stmt->bindParam(':email_address', $email);
		$stmt->execute();

		$count = $stmt->fetchColumn(); 

		return $count > 0;
	}
	
	/*
	  Register a new account.
	  
	  $extra is JSON data stored along with the user, and 
	  returned from a login call.
	  
	  Return is an array with values:
	    success = true or false
	    userid = user ID if success
	    reason = textual reason registration failed
	    reasonCode = numeric code explaining why registration failed
	    authToken = token used to authenticate future requests
	    
	  reasonCode can be:
	    100 = account exists
	    101 = invalid parameters
	    500 = unexpected error
	*/
	public function register($email, $password, $extra) {
		if (strlen($email) < 5 || strlen($password) == 0) {
			return array('success' => false, 
			             'reasonCode' => 101, 
			             'reason' => 'email address or password invalid');
			return $response;
		}
		
		$password_hash = password_hash($password, PASSWORD_DEFAULT);
		$auth_token = bin2hex(openssl_random_pseudo_bytes(16));

		$stmt = $this->config->db->prepare("INSERT INTO bek_users (email, password_hash, auth_token, extra) VALUES (:email, :password_hash, :auth_token, :extra)");
		$stmt->bindParam(':email', $email);
		$stmt->bindParam(':password_hash', $password_hash);
		$stmt->bindParam(':auth_token', $auth_token);
		$stmt->bindParam(':extra', $extra);
		if (!$stmt->execute()) {
			// Check for duplicate
			$errorInfo = $stmt->errorInfo();
			
			// Check for SQLSTATE value that indicates a primary key uniqueness violation
			if ($errorInfo[0] == 23000) {
				return array('success' => false,
			    	         'reasonCode' => 100, 
							 'reason' => 'email address already registered');
			}
			
			return array('success' => false, 
		    	         'reasonCode' => 500, 
						 'reason' => 'unexpected database error');
		}

        $userid = $this->config->db->lastInsertId();
        if ($this->config->requireEmailValidation) {
            return array('success' => true, 'userid' => $userid);
        } else {
            // Return the token
            return array('success' => true,
                'userid' => $userid,
                'authToken' => $auth_token);
        }
	}

    /*
     * Helper function to update the number of failed logins
     */
    private function updateWithFailedLogin($email, $numFailedLogins) {
        $stmt = $this->config->db->prepare("UPDATE bek_users SET num_failed_logins=:num_failed_logins, date_last_failed_login = CURRENT_TIMESTAMP WHERE email = :email");
        $stmt->bindParam(':num_failed_logins', $numFailedLogins);
        $stmt->bindParam(':email', $email);
        if (!$stmt->execute()) {
            die('internal error');
        }
    }

    /*
    * Helper function to update after a successful login
    */
    private function processLoginSuccess($email) {
        $stmt = $this->config->db->prepare("UPDATE bek_users SET num_failed_logins = 0, date_last_failed_login = NULL, date_last_login = CURRENT_TIMESTAMP WHERE email = :email");
        $stmt->bindParam(':email', $email);
        if (!$stmt->execute()) {
            die('internal error');
        }
    }

    private function shouldThrottleLogin($lastFailedLoginTime, $numTries) {
        if ($numTries > 4) {
            return (time() - $lastFailedLoginTime) < 5;
        } else {
            return false;
        }
    }

    /*
     * Combined login function that logs in, verifying the account if the token is supplied and matches.
     */
    private function loginWithVerificationToken($email, $password, $token) {
        $stmt = $this->config->db->prepare("SELECT id, password_hash, auth_token, extra, email_verified, verification_token, unix_timestamp(date_last_failed_login) as date_last_failed_login, num_failed_logins FROM bek_users WHERE email = :email");
        $stmt->bindParam(':email', $email);
        if (!$stmt->execute()) {
            return array('success' => false,
                'reasonCode' => 502,
                'reason' => 'internal error');
        }

        if ($this->shouldThrottleLogin($row['date_last_failed_login'], $row['num_failed_logins'])) {
            return array('success' => false,
                'reasonCode' => 429,
                'reason' => 'request throttled; try again in a few seconds');
        }

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            return array('success' => false,
                'reasonCode' => 403,
                'reason' => 'unable to authenticate');
        }

        if (!password_verify($password, $row['password_hash'])) {
            $this->updateWithFailedLogin($email, $row['num_failed_logins']+1);
            return array('success' => false,
                'reasonCode' => 403,
                'reason' => 'unable to authenticate');
        }

        if ($this->config->requireEmailValidation && !$row['email_verified']) {
            if ($token && $row['verification_token'] == $token) {
                $vstmt = $this->config->db->prepare("UPDATE bek_users SET email_verified=1 WHERE id=:userid");
                $vstmt->bindParam(':userid', $row['id']);
                $vstmt->execute();
            } else {
                return array('success' => false,
                    'reasonCode' => 103,
                    'reason' => 'email address not verified');
            }
        }

        return array('success' => true,
            'authToken' => $row['auth_token'],
            'userid' => $row['id'],
            'extra' => $row['extra']);
    }

	/*
	  Login
	  
	  Return is an array with values:
	    success = true or false
	    authToken = authentication token, if success
	    extra = extra data, if success
	    reason = textual reason registration failed
	    reasonCode = numeric code explaining why registration failed
	*/
	public function login($email, $password) {
        $stmt = $this->config->db->prepare("SELECT id, password_hash, auth_token, extra, email_verified, verification_token, unix_timestamp(date_last_failed_login) as date_last_failed_login, num_failed_logins FROM bek_users WHERE email = :email");
        $stmt->bindParam(':email', $email);
        if (!$stmt->execute()) {
            die("internal error");
        }

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            return array('success' => false,
                'reasonCode' => 403,
                'reason' => 'unable to authenticate');
        }

        if ($this->shouldThrottleLogin($row['date_last_failed_login'], $row['num_failed_logins'])) {
            return array('success' => false,
                'reasonCode' => 429,
                'reason' => 'request throttled; try again in a few seconds');
        }

        if (!password_verify($password, $row['password_hash'])) {
            $this->updateWithFailedLogin($email, $row['num_failed_logins']+1);
            return array('success' => false,
                'reasonCode' => 403,
                'reason' => 'unable to authenticate');
        }

        if ($this->config->requireEmailValidation && !$row['email_verified']) {
            return array('success' => false,
                'reasonCode' => 103,
                'reason' => 'email address not verified');
        }

        return array('success' => true,
            'authToken' => $row['auth_token'],
            'userid' => $row['id'],
            'extra' => $row['extra']);
	}

    public function verifyEmailAddress($token) {
        $stmt = $this->config->db->prepare("SELECT id, auth_token, extra FROM bek_users WHERE verification_token = :verification_token");
        $stmt->bindParam(":verification_token", $token);
        if (!$stmt->execute()) {
            die("internal error");
        }

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            return array('success' => false,
                'reasonCode' => 405,
                'reason' => 'token is not valid');

        }

        $vstmt = $this->config->db->prepare("UPDATE bek_users SET email_verified=1, verification_token = null WHERE id=:userid");
        $vstmt->bindParam(':userid', $row['id']);
        if (!$vstmt->execute()) {
            die("internal error");
        }

        return array('authToken' => $row['auth_token'], 'extra' => $row['extra']);
    }

    public function newVerificationToken($userID) {
        $token = md5(uniqid(rand(), TRUE));
        $stmt = $this->config->db->prepare("UPDATE bek_users SET verification_token = :token WHERE id = :id");
        $stmt->bindParam(':token', $token);
        $stmt->bindParam(':id', $userID);
        if (!$stmt->execute()) {
            return null;
        }
        return $token;
    }

    public function checkValidationToken($token) {
        if (!$token) {
            return null;
        }

        $stmt = $this->config->db->prepare("SELECT id FROM bek_users WHERE verification_token = :token");
        $stmt->bindParam(':token', $token);
        if (!$stmt->execute() || $stmt->rowCount() != 1) {
            return null;
        }
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            return null;
        }

        return $row['id'];
    }

    public function authTokenFromEmail($email) {
        $stmt = $this->config->db->prepare("SELECT auth_token FROM bek_users WHERE email = :email");
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['auth_token'];
    }

    public function verificationTokenFromEmail($email) {
        $stmt = $this->config->db->prepare("SELECT verification_token FROM bek_users WHERE email = :email");
        $stmt->bindParam(':email', $email);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        return $row['verification_token'];
    }

    public function sendValidationEmailForAccount($userID) {
        $stmt = $this->config->db->prepare("SELECT email FROM bek_users WHERE id = :userid");
        $stmt->bindParam(':userid', $userID);
        $stmt->execute();
        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            return array('success' => 'false', 'reason' => 'account not found', 'reasonCode' => 410);
        }

        $email = $row['email'];
        $template = file_get_contents(dirname(__FILE__) . "/../../templates/emailAddressValidation.txt");
        $token = $this->newVerificationToken($userID);
        $link = $this->config->webRoot . "api/v1/login.php?vt=" . $token;
        $message = str_replace("{{link}}", $link, $template);
        $headers = "From: " . $this->config->emailFrom;
        if (mail($email, "Verify Account", $message, $headers)) {
            return array('success' => 'true');
        } else {
            return array('success' => 'false', 'reason' => 'unable to send mail', 'reasonCode' => 503);
        }
    }

    public function sendForgotPasswordEmail($email) {
        $stmt = $this->config->db->prepare("SELECT id, unix_timestamp(date_last_password_reset) as date_last_password_reset FROM bek_users WHERE email = :email");
        $stmt->bindParam(':email', $email);
        if (!$stmt->execute()) {
            die("internal error");
        }

        $row = $stmt->fetch(PDO::FETCH_ASSOC);
        if (!$row) {
            return array('success' => 'false', 'reason' => 'account not found', 'reasonCode' => 410);
        }

        $lastSent = $row['date_last_password_reset'];
        if (isset($lastSent) && (time() - $lastSent < 60)) {
            // Throttle: don't send more than one password reset email to an email
            // address per minute
            return array('success' => false,
                'reasonCode' => 429,
                'reason' => 'request throttled; try again in a few seconds');
        }

        $userid = $row['id'];
        $template = file_get_contents(dirname(__FILE__) . "/../../templates/forgotPassword.txt");
        $token = $this->newVerificationToken($userid);
        $link = $this->config->webRoot . "api/v1/resetPassword.php?vt=" . $token;
        $message = str_replace("{{link}}", $link, $template);
        $headers = "From: " . $this->config->emailFrom;
        if (mail($email, "Reset Password", $message, $headers)) {
            $this->config->db->exec("UPDATE bek_users SET date_last_password_reset = CURRENT_TIMESTAMP WHERE id = " . $userid);
            return array('success' => 'true');
        } else {
            return array('success' => 'false', 'reason' => 'unable to send mail', 'reasonCode' => 503);
        }
    }

    public function resetPassword($vt, $newpass) {
        $stmt = $this->config->db->prepare("UPDATE bek_users SET password_hash = :hash WHERE verification_token = :vt");
        $hash = password_hash($newpass, PASSWORD_DEFAULT);
        $stmt->bindParam(':hash', $hash);
        $stmt->bindParam(':vt', $vt);
        if (!$stmt->execute()) {
            die("internal error");
        }

        if ($stmt->rowCount() == 1) {
            return array('success' => true);
        } else {
            return array('success' => false, 'reason' => 'verification token not found', 'reasonCode', 407);
        }
    }

    public function lookupAuthToken($authToken) {
        $stmt = $this->config->db->prepare("SELECT email, email_verified, password_hash FROM bek_users WHERE auth_token=:token");
        $stmt->bindParam(':token', $authToken);
        if (!$stmt->execute()) {
            return array('success' => false,
                'reasonCode' => 502,
                'reason' => 'internal error');
        }

        $row = $stmt->fetch(PDO::FETCH_ASSOC);

        if (!$row) {
            return array('success' => false,
                'reasonCode' => 403,
                'reason' => 'unable to authenticate');
        }

        if ($this->config->requireEmailValidation && !$row['email_verified']) {
            return array('success' => false,
                'reasonCode' => 103,
                'reason' => 'email address not verified');
        }

        return array('email' => $row['email'], 'passwordHash' => $row['password_hash']);
    }

    public function changePassword($authToken, $password, $newpass) {
        $result = $this->lookupAuthToken($authToken);

        if (empty($result['passwordHash'])) {
            return array('success' => false, 'reasonCode' => '403', 'reason' => 'invalid token');
        }

        if (!password_verify($password, $result['passwordHash'])) {
            return array('success' => false, 'reasonCode' => '403', 'reason' => 'unable to authenticate');
        }

        $hash = password_hash($newpass, PASSWORD_DEFAULT);

        $stmt = $this->config->db->prepare("UPDATE bek_users SET password_hash = :hash WHERE auth_token = :auth_token");
        $hash = password_hash($newpass, PASSWORD_DEFAULT);
        $stmt->bindParam(':hash', $hash);
        $stmt->bindParam(':auth_token', $authToken);
        if (!$stmt->execute()) {
            die("internal error");
        }

        if ($stmt->rowCount() == 1) {
            return array('success' => true);
        } else {
            return array('success' => false, 'reason' => 'authentication token not found', 'reasonCode', 403);
        }
    }

    public function updateExtra($authToken, $extra) {
        $stmt = $this->config->db->prepare("UPDATE bek_users SET extra = :extra WHERE auth_token = :token");
        $stmt->bindParam(':token', $authToken);
        $stmt->bindParam(':extra', $extra);
        if (!$stmt->execute() || $stmt->rowCount() != 1) {
            return false;
        }
        return true;
    }
}

?>
