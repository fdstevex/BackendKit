<?php

/**
 * @backupGlobals disabled
 * @backupStaticAttributes disabled
 */

require_once(dirname(__FILE__) . "/../kitroot.php");

class BEKUserDBTest extends PHPUnit_Framework_TestCase {
    public function testCreateAccount() {
        $userdb = new BEKUserDB();
        $userdb->config->requireEmailValidation = false;

        assert(isset($userdb));

        assert($userdb->deleteAccount('test@example.com'));
        assert(!$userdb->accountExists('test@example.com'));
        $response = $userdb->register('test@example.com', 'secret', '{ "itWorked": 1 }');
        assert($response);
        assert($response['success']);
    }

    public function testDeleteAccount() {
        $userdb = new BEKUserDB();
        $userdb->config->requireEmailValidation = false;

        assert($userdb->deleteAccount('test@example.com'));
        assert(!$userdb->accountExists('test@example.com'));
        $response = $userdb->register('test@example.com', 'secret', '{ "itWorked": 1 }');
        assert($response);
        assert($response['success']);
        assert($userdb->deleteAccount('test@example.com'));
        assert(!$userdb->accountExists('test@example.com'));
    }

    public function testExtraData() {
        $userdb = new BEKUserDB();
        $userdb->config->requireEmailValidation = false;
        assert(isset($userdb));

        $userdb->deleteAccount('test@example.com');
        assert(!$userdb->accountExists('test@example.com'));
        $account = $userdb->register('test@example.com', 'secret', '{ "itWorked": 1 }');
        assert($account);
    }

    public function testAuthenticate() {
        $userdb = new BEKUserDB();
        $userdb->config->requireEmailValidation = true;
        assert(isset($userdb));
        assert($userdb->deleteAccount('test@example.com'));
        $response = $userdb->register('test@example.com', 'secret', '{ "itWorked": 1 }');
        assert($response);
        assert($response['success']);

        $userdb->sendValidationEmailForAccount($response['userid']);

        $token = $userdb->verificationTokenFromEmail('test@example.com');
        print "Verification token: " . $token . "\n";

        $response = $userdb->verifyEmailAddress($token);
        assert($response);
        assert(isset($response['authToken']));

        // Second verification of the same token should fail
        $response = $userdb->verifyEmailAddress($token);
        assert(!isset($response['authToken']));
    }

    public function testVerificationToken() {
        $userdb = new BEKUserDB();
        $userdb->config->requireEmailValidation = false;
        assert($userdb->deleteAccount('test@example.com'));
        $response = $userdb->register('test@example.com', 'secret', null);
        $userid = $response['userid'];
        $token = $userdb->newVerificationToken($userid);
        assert(isset($token));
        $newuserid = $userdb->checkValidationToken($token);
        assert($userid == $newuserid);
        $response = $userdb->resetPassword($token, 'booga');
        assert($response['success']);
    }

    public function testChangePassword() {
        $userdb = new BEKUserDB();
        $userdb->config->requireEmailValidation = false;
        assert($userdb->deleteAccount('test@example.com'));
        $response = $userdb->register('test@example.com', 'secret', null);
        $authToken = $response['authToken'];
        $response = $userdb->changePassword($authToken, 'secret', 'secret2');
        assert($response['success'] == true);
        $response = $userdb->login('test@example.com', 'secret');
        assert(!isset($response['authToken']));
        $response = $userdb->login('test@example.com', 'secret2');
        assert(isset($response['authToken']));
    }

    public function testMail() {
//        $userdb = new BEKUserDB();
//        $userdb->sendValidationEmailForAccount("xsteve@gmail.com");
    }
}
