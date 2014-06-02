# app/client/lobby/login.coffee

# events
Template.loginButtons.events
  'click #login-facebook': ->
    Meteor.loginWithFacebook (err) ->
      if err?
        FlashMessages.sendError "Kunne ikke logge ind"
        console.log(err)
      else
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
        FlashMessages.sendSuccess "Logget ind"


  'click #login-create': (evt) ->
    evt.preventDefault()

    email = "#{$('input#email').val()}".replace /^\s+|\s+$/g, ""
    password = "#{$('input#password').val()}".replace /^\s+|\s+$/g, ""

    pattern = /// ^
      (([^<>()[\]\\.,;:\s@\"]+
      (\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))
      @((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}
      \.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+
      [a-zA-Z]{2,}))$ ///
    unless email.match pattern
      FlashMessages.sendError 'Ugyldig email adresse'
      return

    Accounts.createUser {
      username: email
      password: password
      email: email }
    , (err) ->
      if err?
        if err.error == 403
          FlashMessages.sendError "Brugernavn taget"
        else
          FlashMessages.sendError "Kunne ikke oprette bruger"
          console.log err
      else
        FlashMessages.sendSuccess "Bruger oprettet"

Template.currentUser.events
  'click #logout': (event) ->
    Meteor.logout (err) ->
      if err?
        FlashMessages.sendError 'Kunne ikke logge ud'
        console.log err
      else
        FlashMessages.sendSuccess 'Logget ud'
