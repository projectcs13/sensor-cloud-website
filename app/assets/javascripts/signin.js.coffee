$ ->
    # window.signinCallback = (authResult) ->
    #     if authResult['status']['signed_in']
    #         # Update the app to reflect a signed in user
    #         # Hide the sign-in button now that the user is authorized, for example:
    #         document.getElementById('g-btn').setAttribute('style', 'display: none')
    #         $.post '/users/auth/google/', authResult
    #     else
    #         # Update the app to reflect a signed out user
    #         # Possible error values:
    #         #   "user_signed_out" - User is signed-out
    #         #   "access_denied" - User denied access to your app
    #         #   "immediate_failed" - Could not automatically log in the user
    #         console.log('Sign-in state: ' + authResult['error'])

    #     console.log(authResult);
    window.signinCallback = (authResult) ->
        # if authResult['code']
        if authResult['status']['signed_in']

            # Hide the sign-in button now that the user is authorized, for example:
            # $('#signinButton').attr('style', 'display: none')
            document.getElementById('g-btn').setAttribute('style', 'display: none')
            console.log authResult['code']

            # TESTING
            url = "https://www.googleapis.com/plus/v1/people/me"
            $.get url, (data) ->
                console.log data



            # Send the code to the server
            res = $.post '/users/auth/google/', authResult
            res.done (result) ->
                console.log(result)
                if result['profile'] and result['people']
                    console.log 'Hello #{result["profile"]["displayName"]}. You successfully made a server side call to people.get and people.list'
                else
                    console.log 'Failed to make a server-side call. Check your configuration and console.'
            # $.ajax
            #     type: 'POST'
            #     url: '/users/auth/google/'
            #     contentType: 'application/octet-stream; charset=utf-8'
            #     processData: false
            #     data: authResult['code']
            #     success: (result) ->
            #         # Handle or verify the server response if necessary.

            #         # Prints the list of people that the user has allowed the app to know to the console.
            #         console.log(result)
            #         if result['profile'] and result['people']
            #             console.log 'Hello #{result["profile"]["displayName"]}. You successfully made a server side call to people.get and people.list'
            #         else
            #             console.log 'Failed to make a server-side call. Check your configuration and console.'

        else if authResult['error']
        # There was an error.
        # Possible error codes:
        #   "access_denied" - User denied access to your app
        #   "immediate_failed" - Could not automatially log in the user
            console.log('There was an error: ' + authResult['error'])



    params = {
        'clientid' : '995342763478-fh8bd2u58n1tl98nmec5jrd76dkbeksq.apps.googleusercontent.com'
        'cookiepolicy' : 'single_host_origin'
        'callback' : window.signinCallback
        'requestvisibleactions' : 'http://schemas.google.com/AddActivity http://schemas.google.com/CommentActivity'
    }

    # gapi.signin.render "g-btn", params
