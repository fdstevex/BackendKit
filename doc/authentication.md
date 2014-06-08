BackendKit Authentication Service
=================================

BackendKit offers a simple authentication service, that attempts to be secure and follow reasonable best practices, while remaining lightweight. It doesn't do everything, and whether you consider this a feature or a drawback depends on your perspective.

This document is an overview; for the details, see the API documentation.

Registration
------------
Accounts are created via an HTTP POST.  A client submits an email address and password, and an account is created if there isn't already an account with that email address. (If there is, an error is returned).

Email address validation
------------------------
Email address verification is supported, and is recommended, but you can turn it off during development.

If enabled, then when an account is registered, an email is generated (using the template in the templates folder), including a link with a validation token. When the user clicks this link, their account is marked as verified, and an authToken is returned.

Login
-----
Clients log in via a POST of their email address and password. A successful login yields an authToken.

Forgotten Passwords
-------------------
An API endpoint is available where the user can submit an email address to request an account recovery link. The account recovery link is similar to the email validation link, except that once the user clicks it, they will be able to enter a new password.

Extra Data
----------
The registration request supports a 'extra' parameter that you can use to include a JSON structure that will be stored along along with the user information, and returned when logging in. This can be used to store a display name, profile description, or any other small amount of user data you need to store.

You can update the extra data by PUTing new data to the login endpoint.

Client Support
==============
There are two anticipated client types for the service.  Pure HTML clients will depend on the login endpoint redirecting back to an HTML page once the login is complete. For this type of client, redirection is supported, and the authentication token is set as a cookie.

For API based clients, such as apps, or AJAX style login, information is returned as JSON.

Login information is returned as JSON, as well as in cookies: BEKAuthToken is the authentication token, and in the event of an error, two cookies will be set: BEKLastReason and BEKLastReasonCode. These return a short English description of the problem, as well as a numeric code that can be used to look up a localized description.  An HTML client should check for the cookie, show the message, and then clear the cookie.


Security Notes
==============
One of the goals of BackendKit is to be reasonably secure. Security is a continuum, and the security needs of applications will differ. Read this section before deciding that BackendKit is right for you.

Some things that BackendKit's authentication does not do:

* Support OAuth
* Support login via Twitter or Facebook
* Support two-factor authentication
* Expire tokens.
* Push or poll for token expiry (to attempt to "revoke" a client in real-time)

These are all reasonable things to support, and may be supported some day, but the system is quite usable for the basic use cases it was designed for without them.

Passwords
---------
Passwords are "hashed" using PHP's password_hash function, which produces a salted password using some amount of complexity to make attacks difficult in the event that the database is compromised.

Password complexity is not enforced, other than that the password must not be empty.

HTTPS
-----
It is expected that all clients will connect using HTTPS. This isn't enforced in the code, but if you're sending the user's credentials around as plaintext, you're asking for trouble.

Token Management
----------------
There is one authentication token per account, which is used by any client logging in with that account. This means you can't revoke one device's access; revoking the token means every client will need to log in again.

The token doesn't expire. Once a user logs in, their token will work forever.

XSRF Cookie
-----------
In order to mitigate session hijacking, BackendKit uses double-submit cookies for authenticated requests.

Any request that's authenticated via BEKAuthToken must also include a value in a cookie called BEKCSRF that matches a request parameter with the same name.

To Do
-----
* Throttling of account registration confirmation emails
* Throttling of login attempts
* Throttling of reset password attempts



