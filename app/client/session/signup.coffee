# app/client/session/signup.coffee

# events
Template.signup.events
  'click #signup': (evt) ->
    evt.preventDefault()

    name = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
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

    Accounts.createUser
      username: email
      password: password
      email: email
      profile: { name: name }
    , (err) ->
      if err?
        if err.error == 403
          FlashMessages.sendError "Brugernavn taget"
        else
          FlashMessages.sendError "Kunne ikke oprette bruger"
          console.log err
      else
        Meteor.users.update
        Router.go 'lobby'
        FlashMessages.sendSuccess "Bruger oprettet"
