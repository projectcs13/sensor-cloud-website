window.signinCallback = (authResult) ->
    gapi.client.load 'plus','v1', ->
        $('#authResult').html('Auth Result:<br/>')
        for field in authResult
            $('#authResult').append(' ' + field + ': ' + authResult[field] + '<br/>')

        if authResult['access_token']
            $('#authOps').show('slow')
            $('#gConnect').hide()
            helper.profile()
            helper.people()
        else if authResult['error']
            # There was an error, which means the user is not signed in.
            # As an example, you can handle by writing to the console:
            console.log('There was an error: ' + authResult['error'])
            $('#authResult').append('Logged out')
            $('#authOps').hide('slow')
            $('#gConnect').show()

        console.log('authResult', authResult)


# window.signinCallback = (authResult) ->
#     # if authResult['code']
#     console.log "signinCallback"
#     console.log authResult
#     # console.log authResult['status']

#     res = $.post '/users/auth/google/', authResult
#     res.done (res) ->
#         console.log("signinCallback done")
#         console.log(res)
#         # if not error
#         authorize res


authorize = (html) ->
    iframe = do createIframe html
    # redirect iframe, token_url
    # dom = $(html)
    # $(iframe).html dom


redirect = (iframe, location)->
    iframe.src = location


createIframe = (html) ->
    iframe = document.createElement 'iframe'
    # iframe.src = 'data:text/html;charset=utf-8,' + encodeURI html
    $(iframe).html html
    document.body.appendChild iframe
    console.log 'iframe.contentWindow =', iframe.contentWindow
    iframe

    # # Possible error codes:
    # #   "access_denied" - User denied access to your app
    # #   "immediate_failed" - Could not automatially log in the user
