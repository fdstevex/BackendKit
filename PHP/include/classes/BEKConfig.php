<?php

class BEKConfig {
    /*
     * PDO database object.
     */
    var $db;

    /*
     * Path to the root of the website.  Used when building URLs.  Must include
     * the trailing slash.
     */
    var $webRoot;

    /*
     * When sending email, this is the "from" address.
     */
    var $emailFrom;

    /*
     * When set, new account creation triggers sending an validation email with a link
     * containing a token that's used to verify that the user owns the email address they
     * have supplied.
     */
    var $requireEmailValidation;

    /*
     * Where to redirect a user after they click the login validation page and successfully
     * log in.
     */
    var $emailValidationSuccessPage;

    /*
     * Where to redirect a user after they click the login validation page and successfully
     * log in.
     */
    var $emailValidationFailurePage;

    /*
     * Redirect upon click on the "forgot password" link in an email.
     */
    var $forgotPasswordFormPage;

    /*
     * Redirect upon click on the "forgot password" link in an email with
     * an invalid token.
     */
    var $forgotPasswordTokenInvalidPage;

    /*
     * Lifetime to use for the authorization cookie.
     */
    var $authCookieLifetime;

    /*
     * Defaults
     */
    function __construct() {
        // Defaults
        $this->authCookieLifetime = time() + (60*60*24*365);
        $this->emailValidationSuccessPage = "html/verify-thanks.html";
        $this->emailValidationFailurePage = "html/verify-error.html";
        $this->forgotPasswordFormPage = "html/resetpass/newpass.html";
        $this->forgotPasswordTokenInvalidPage= "html/resetpass/forgotpass-error.html";
    }
}

?>
