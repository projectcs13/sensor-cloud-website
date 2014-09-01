require 'google/api_client'
require 'google/api_client/client_secrets'

# Configuration
# The Google OAuth 2.0 and OpenIDConnect client library gets
# the information from the client_secrets.json file

PLUS_LOGIN_SCOPE = 'https://www.googleapis.com/auth/plus.login'

# Build the global client
$credentials = Google::APIClient::ClientSecrets.load
$authorization = Signet::OAuth2::Client.new(
    :authorization_uri => $credentials.authorization_uri,
    :token_credential_uri => $credentials.token_credential_uri,
    :client_id => $credentials.client_id,
    :client_secret => $credentials.client_secret,
    :redirect_uri => $credentials.redirect_uris.first,
    :scope => PLUS_LOGIN_SCOPE)
$client = Google::APIClient.new

