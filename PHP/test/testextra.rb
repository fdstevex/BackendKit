# Simple test for the BackendKit authentication service's
# ability to store extra profile data along with a user.

require 'rest_client'
require 'trollop'
require 'uri'
require 'json'

opts = Trollop::options do
    opt :url, "URL specifying the location of the public folder", :type => :string
    opt :email, "Email address to register as part of the test", :type => :string
end

Trollop::die :url, "required" unless opts[:url]
Trollop::die :email, "required" unless opts[:email]

email = opts[:email]
webroot = opts[:url]
webroot += '/' unless webroot.end_with?('/')

#
# Register an account
#

registerURI = URI::join(webroot, "api/v1/register.php")
loginURI = URI::join(webroot, "api/v1/login.php")

responseJSON = RestClient.post registerURI.to_s, :email => email, :password => 'secret', :extra => '{ "foo": "bar" }'
puts "Registration response: #{responseJSON}"
response = JSON.parse(responseJSON)
abort("Expected authToken") unless response['authToken']

#
# Log in
#

responseJSON = RestClient.post loginURI.to_s, :email => email, :password => 'secret'
abort("Expected registration to succeed") unless response['authToken']
puts "Login response: #{responseJSON}"
response = JSON.parse(responseJSON);
extra = JSON.parse(response['extra']);
token = response['authToken'];
abort("Missing extra data") unless extra['foo'] == 'bar';

puts "Token=#{token}"

# PUT an update to the extra user data
puts "Testing PUT with no cookie"
begin
    response = RestClient.put loginURI.to_s, {:authToken => token, :extra => '{ "foo": "second" }'}
rescue RestClient::Forbidden
    # This is what we expect - a 403 because of no CSRF cookie
else
    abort("Expected PUT with no CSRF cookie to fail")
end

puts "Testing PUT with cookie"
response = RestClient.put loginURI.to_s, {:authToken => token, :extra => '{ "foo": "second" }', :BEKCSRF => '12345678'}, {:cookies => { :BEKCSRF => '12345678' }}
abort("Unexpected response from PUT") unless response.code == 200

# Log in again and make sure we get it back

responseJSON = RestClient.post loginURI.to_s, :email => email, :password => 'secret'
puts "Login response: #{responseJSON}"
abort("Unexpected response from login") unless responseJSON.code == 200
response = JSON.parse(responseJSON);
extra = JSON.parse(response['extra']);
token = response['authToken'];
abort("Missing extra data") unless extra['foo'] == 'second';
