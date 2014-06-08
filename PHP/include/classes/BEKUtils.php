<?php
/**
 * Created by PhpStorm.
 * User: stevex
 * Date: 2014-04-19
 * Time: 7:28 AM
 */

class BEKUtils {
    /**
     * Every call to any authenticated API must include a
     * cookie called BEKCSRF whose value must match a request
     * parameter.  This mechanism allows for stateless
     * CSRF mitigation.
     * https://www.owasp.org/index.php/Cross-Site_Request_Forgery_(CSRF)_Prevention_Cheat_Sheet#Double_Submit_Cookies
     */
    public static function checkCSRFCookie($put_vars = null) {
        $cookie = $_COOKIE['BEKCSRF'];
        if (!isset($cookie)) {
            http_response_code(403);
            die("missing BEKCSRF cookie");
        }

        if (strlen($cookie) < 8) {
            http_response_code(403);
            die("invalid BEKCSRF cookie (too short)");
        }

        if (isset($put_vars)) {
            $putToken = $put_vars['BEKCSRF'];
        } else {
            $putToken = null;
        }

        # Look for the cookie in POST, GET or PUT variables.  Can't use $_REQUEST because that
        # includes cookies, and we need to find it in both places.
        if ($cookie != $_POST['BEKCSRF'] && $cookie != $_GET['BEKCSRF'] && $cookie != $putToken) {
            http_response_code(403);
            die("CSRF cookie doesn't match request");
        }
    }
} 