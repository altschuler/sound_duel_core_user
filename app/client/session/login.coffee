# app/client/session/login.coffee

# events
Template.login.events
  'click #login-facebook': ->
    Meteor.loginWithFacebook (err) ->
      if err?
        if err.error == 403
          FlashMessages.sendError "Email allerede registreret"
        else
          FlashMessages.sendError "Kunne ikke logge ind"
        console.log(err)
      else
        Router.go 'lobby'
        FlashMessages.sendSuccess "Logget ind"

  'click #login-password': (evt) ->
    evt.preventDefault()

    username = "#{$('input#email').val()}".replace /^\s+|\s+$/g, ""
    password = "#{$('input#password').val()}".replace /^\s+|\s+$/g, ""

    Meteor.loginWithPassword username, password, (err) ->
      if err?
        if err.error == 403
          FlashMessages.sendError "Forkert brugernavn eller passord"
        else
          FlashMessages.sendError "Kunne ikke logge ind"
          console.log err
      else
        Router.go 'lobby'
        FlashMessages.sendSuccess "Logget ind"
