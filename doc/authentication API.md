# Overview

BackendKit's authentication service is based on four endpoints, each of which support either API style calls returning JSON, or HTML-friendly calls which respond by redirecting and passing status through cookies.

Documentation expressed as curl commands, which reference an $BEKROOT variable. This would be the URL of the "public" folder in the BackendKit project.

# Registration

    /api/v1/register

To register a new user, POST the email address and password.

    curl -F "email=foo@bar.com" -F "password=secret" $WEBROOT/api/v1/register.php

Parameters:

* **email** is the email address to register
* **password** is the password for the new account
* **extra** is a string of additional data to associate with the account
* **redirect** is the site-relative URL to redirect to when complete

The **extra** parameter can be used to associate user profile data, such as a display name or avatar URL, with an account. It is returned upon login and can be updated by POSTing new extra data to /login.

If the redirect paramater is supplied, then the resonse includes a redirect to the URL specified, appended to the site root (set in config.php).

Otherwise, the response is JSON, and looks like this:

    {"authToken":"8bad27f82cd983ce9c31ae0e9862903c"}

Or, on a typical failure:

    {"success":false,"reasonCode":100,"reason":"email address already registered"}

On redirect, the result is returned in cookies, either BEKAuthToken, or BEKReason and BEKReasonCode. These are session cookies, and the expectation is that the redirect target would read the cookies, display the message, and then delete the cookies.

If email validation is required, then a successful response will not include the authentication token, but will indicate that the validation email was sent:

    {"success":true,"reasonCode":102,"reason":"validation email sent"}

Once the user clicks the link in the validation email, they will get a token.

# Login

    /api/v1/login

Upon receiving the correct email address and password, returns the user's authentication token.

    curl -F "email=foo@bar.com" -F "password=secret" $WEBROOT/api/v1/login.php

Response will be

    {"authToken":"054c735574aa7215a4819df07022343c", "extra":"{}"}

or

    {"success":false,"reasonCode":403,"reason":"unable to authenticate"}

The same redirect and cookie response pattern is used for HTML clients as with the login endpoint.

### Update Extra Data

    curl -X PUT -F "authToken=054c735574aa7215a4819df07022343c" -F "extra=['json','data']" $WEBROOT/api/v1/login.php

This replaces the extra data with new content.

## Email Address Verification

As part of the email verification process, the user will receive a login link containing a verification token. This link points to /api/v1/login, and passes the token as the vt parameter.

    curl -v $WEBROOT/api/v1/login.php?vt=4819df02343c054c735574aa7215a702

Since email verification only happens from a browser (it wouldn't make sense from native clients - to verify their email address, the user is clicking on a link that will launch in a browser) the response is either a redirect to a success page, or a redirect to an error page.  The pages to redirect to are configurable in config.php (emailValidationSuccessPage and emailValidationFailurePage).

The success page can include a link back to the native application (using an URL scheme) to keep the user from having to go find the application themselves at this point.

# Password Reset

    /api/v1/resetPassword

Users forget their passwords.

POST email to /api/v1/resetPassword to send the user a link that, when clicked, will redirect them to a reset password page where they can enter a new password. The link is configured in config.php, variable forgotPasswordFormPage.

    curl -F "email=test@example.com" $WEBROOT/api/v1/resetPassword

Response will be

    {"success":"true"}

Or if a redirect variable is included, the user will be redirected to that location relative to the site root.

## Password Reset Process: Link Click

    curl $WEBROOT/api/v1/resetPassword?vt=5a4819df07022343c5a4819df07022343c

The user is redirected to the page where they can enter their new password, or if the token isn't correct, they are redirected to the configured forgotPasswordTokenInvalidPage.

## Password Reset Process: New Password

Finally, a POST with vt and newpassword performs the password reset.

    curl -F "vt=5a4819df07022343c5a4819df07022343c" -F "newpassword=secret" $WEBROOT/api/v1/resetPassword

Response is {407, token is not valid} or is a similar response to a successful login (including an authToken).
