# Simple test for the BackendKit authentication service.
#
# Specify the path to the public folder on your test webserver, and
# optionally a base email address to use for account creation.
#
# This requires email validation be turned off for your test
# server, which is usually the case anyway.

require 'rest_client'
require 'trollop'
require 'uri'
require 'json'
require 'cgi'

opts = Trollop::options do
    opt :url, "URL specifying the location of the public folder", :type => :string
    opt :email, "Email address to register as part of the test", :type => :string
    opt :dbuser, "MySQL database login", :type => :string
    opt :dbpass, "MySQL database password", :type => :string
end

Trollop::die :url, "required" unless opts[:url]
Trollop::die :email, "required" unless opts[:email]

email = opts[:email]
webroot = opts[:url]
webroot += '/' unless webroot.end_with?('/')

dbuser = opts[:dbuser]
dbpass = opts[:dbpass]

#
# Register an account
#

registerURI = URI::join(webroot, "api/v1/register.php")

responseJSON = RestClient.post registerURI.to_s, :email => 'bad'
response = JSON.parse(responseJSON)
abort("Expected invalid params to fail") if response['success']

responseJSON = RestClient.post registerURI.to_s, :email => email, :password => 'secret'
puts "Registration response: #{responseJSON}"
abort("Expected cookie (make sure config not set to require email validation)") unless responseJSON.headers[:set_cookie].to_s.include?('BEKAuthToken');
response = JSON.parse(responseJSON)
abort("Expected authToken") unless response['authToken']

#
# Log in
#

loginURI = URI::join(webroot, "api/v1/login.php")
responseJSON = RestClient.post loginURI.to_s, :email => email, :password => 'secret'
abort("Expected registration to succeed") unless response['authToken']
puts "Login response: #{responseJSON}"

#
# Send Reset Password Email
#

oldtoken = `mysql backendkit -u #{dbuser} -p#{dbpass} -e "SELECT verification_token FROM bek_users WHERE email=\'test@example.com\'"`

resetPasswordURI = URI::join(webroot, "api/v1/resetPassword.php")
responseJSON = RestClient.post(resetPasswordURI.to_s, :email => email) { |response, request, result, &block|
 if [301, 302, 307].include? responseJSON.code
    response.follow_redirection(request, result, &block)
  else
    response.return!(request, result, &block)
  end
}

abort("Expected reset password email request to succeed") unless responseJSON['success']
puts "Reset password request response: #{responseJSON}"

newtoken = `mysql backendkit --skip-column-names -u #{dbuser} -p#{dbpass} -e "SELECT verification_token FROM bek_users WHERE email=\'test@example.com\'"`
newtoken.strip!
abort("Expected token to change") unless newtoken != oldtoken

# Perform the password change
puts "New verification token: #{newtoken}"

responseJSON = RestClient.post(resetPasswordURI.to_s, :vt => newtoken, :newpassword => 'secret')
response = JSON.parse(responseJSON)
abort("Expected reset password to succeed") unless response['success']

responseJSON = RestClient.post loginURI.to_s, :email => email, :password => 'secret'
response = JSON.parse(responseJSON)
token = response['authToken']
abort("Expected login after password change to succeed") unless token

#
# Change Password
#

responseJSON = RestClient.post resetPasswordURI.to_s, {:BEKAuthToken => token, :password => 'secret', :newpassword => 'secret2', :BEKCSRF => '12345678'}, { :cookies => { :BEKCSRF => '12345678' }}
response = JSON.parse(responseJSON)
abort("Fail resetting password") unless response["success"]
