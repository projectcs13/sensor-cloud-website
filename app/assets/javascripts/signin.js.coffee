$ ->
    window.signinCallback = (authResult) ->
        if authResult['status']['signed_in']
            # Update the app to reflect a signed in user
            # Hide the sign-in button now that the user is authorized, for example:
            document.getElementById('g-btn').setAttribute('style', 'display: none')
            $.post '/users/auth/google/', authResult
        else
            # Update the app to reflect a signed out user
            # Possible error values:
            #   "user_signed_out" - User is signed-out
            #   "access_denied" - User denied access to your app
            #   "immediate_failed" - Could not automatically log in the user
            console.log('Sign-in state: ' + authResult['error'])

        console.log(authResult);


    params = {
        'clientid' : '995342763478-fh8bd2u58n1tl98nmec5jrd76dkbeksq.apps.googleusercontent.com'
        'cookiepolicy' : 'single_host_origin'
        'callback' : window.signinCallback
        'requestvisibleactions' : 'http://schemas.google.com/AddActivity http://schemas.google.com/CommentActivity'
    }

    # gapi.signin.render "g-btn", params
