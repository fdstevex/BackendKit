# BackendKit Server

#### PHP

BackendKit comes with some PHP code that serves as a website starter kit. It provides the authentication back end for your app, including account signup, email address validation (by sending the user an email with a link they use to activate their account), and forgotten passwords.

#### HTML

Since one of the goals of BackendKit is to provide an HTML back-end for your app, a set of HTML files that implement the account management services is also provided.

BackendKit can provide responses in JSON, or it can provide responses in a form that's designed to be consumed by webpages, meaning success or failure is indicated in the HTTP status codes, and error messages are communicated through cookies. 

Typically a request includes a redirect paramter if it's coming from a browser, and the redirect indicates the location to redirect to after the request.  When using a JSON based client (either on the server or in the browser - for example, an AngularJS front end would be JSON based) the responses are indicated in JSON and there is no redirect required.

Details are in the authentication API.md file in /doc.

## Getting Started

1. Set up an account with a web host
2. Set up the MySQL database. Note the database connection details: login, password, and server name.
3. Set up your

## Choosing a web host

If you don't already have a host, there are lots to choose from. Since BackendKit is designed for cheap, commodity hosting, you can pick almost anyone.

I use DreamHost, and have been for almost ten years now. They have shared hosting plans that are inexpensive, and when you grow out of shared hosting, you can upgrade to a VPS and they'll migrate everything over for you. You can sign up for DreamHost here:

http://www.dreamhost.com/r.cgi?165541

Unlimited storage, unlimited bandwidth, $8.95/month.  Sign up using a promo code I created, 'STEVEX', and get a $77 discount on your first year's worth of hosting.

It's this kind of cheap hosting that BackendKit is designed to take advantage of.

## Deployment: The database

Create a MySQL database.  With DreamHost, they set up a PHPMyAdmin instance for your domain at mysql.yourdomain.com.  Go there, click on the SQL tab, and paste in the SQL statements to create the database and the users table (in the mysql/backendkit.sql file).  You can also do this from the command line if you ssh into your account and you're familiar with the MySQL command line, or use MySQLWorkbench, or any other method you're familiar with.

The BackendKit database has one table currently, bek_users, which is where your user information goes.

## Deployment: PHP

Copy the BackendKit PHP files to your hosting account (including hidden files - there is a .htaccess file that won't show up in Finder).

Specify the web directory for your host - the directory it serves as the root directory of your domain - as the PHP/public directory of BackendKit.

## Configuration

In php/include there's a file called config-sample.php.  Copy this file as config.php and edit it. 

Since it's likely that you'll want to build using more than one server - a test server and a production server, for example - the config.php uses different configuration based on the host name.  The sample configuration file uses a server and database on my laptop. If you configure this file for the various places you'll deploy, then you won't need to edit the files or have files that aren't in your SCM on your staging or production server.

The configuration settings described in the config.php file.

## Testing

Verify that the site is working by visiting:

http://yourdomain.com/index.php

If it's working, you should see "Welcome to BackendKit".  If it's not working you'll need to figure out why and fix it before proceeding.

There are some test scripts included, that verify that the web endpoints are all working (except for email validation, which isn't easy to test automatically).  These scripts are written in Ruby and are in the test folder.
