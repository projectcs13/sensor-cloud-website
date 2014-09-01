var helper = (function() {

  var authResult = undefined;

  return {

    /**
     * Hides the sign-in button and connects the server-side app after
     * the user successfully signs in.
     *
     * @param {Object} authResult An Object which contains the access token and
     *   other authentication information.
     */
    onSignInCallback: function(authResult) {
      // $('#authResult').html('Auth Result:<br/>');
      // for (var field in authResult) {
      //   $('#authResult').append(' ' + field + ': ' + authResult[field] + '<br/>');
      // }
      if (authResult['access_token']) {
        // The user is signed in
        this.authResult = authResult;
        helper.connectServer();
        // After we load the Google+ API, render the profile data from Google+.
        // gapi.client.load('plus','v1',this.renderProfile);
        gapi.auth.signOut();
      } else if (authResult['error']) {
        // There was an error, which means the user is not signed in.
        // As an example, you can troubleshoot by writing to the console:
        console.log('There was an error: ' + authResult['error']);
        $('#authResult').append('Logged out');
        $('#authOps').hide('slow');
        $('#gConnect').show();
      }
      console.log('authResult', authResult);
    },

    /**
     * Calls the server endpoint to connect the app for the user. The client
     * sends the one-time authorization code to the server and the server
     * exchanges the code for its own tokens to use for offline API access.
     * For more information, see:
     *   https://developers.google.com/+/web/signin/server-side-flow
     */
    connectServer: function() {
      state   = $('#state').val();
      refresh = this.authResult['code'];

      $.ajax({
        type: 'POST',
        url: window.location.origin + '/auth/in?state=' + state + '&refresh_token=' + refresh,
        contentType: 'application/octet-stream; charset=utf-8',
        success: function(res) {
          if (res.url) {
            window.location.href = res.url;
          }
        },
        error: console.log,
        processData: false,
        data: this.authResult['code']
      });
    }

  };

})();


/**
 * Perform jQuery initialization and check to ensure that you updated your
 * client ID.
 */
$(document).ready(function() {
  if ($('[data-clientid="YOUR_CLIENT_ID"]').length > 0) {
    alert('This sample requires your OAuth credentials (client ID) ' +
          'from the Google APIs console:\n' +
          '    https://code.google.com/apis/console/#:access\n\n' +
          'Find and replace YOUR_CLIENT_ID with your client ID and ' +
          'YOUR_CLIENT_SECRET with your client secret in the project sources.'
    );
  }
});

/**
 * Calls the helper method that handles the authentication flow.
 *
 * @param {Object} authResult An Object which contains the access token and
 *   other authentication information.
 */
window.signinCallback = function(authResult) {
  helper.onSignInCallback(authResult);
}
