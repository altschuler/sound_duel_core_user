# app/client/session/signup.coffee

# events
Template.signup.events
  'click #signup': (evt) ->
    evt.preventDefault()
    error = 0

    name = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
    email = "#{$('input#email').val()}".replace /^\s+|\s+$/g, ""
    password = "#{$('input#password').val()}".replace /^\s+|\s+$/g, ""
    password2 = "#{$('input#password2').val()}".replace /^\s+|\s+$/g, ""

    pattern = /// ^
      (([^<>()[\]\\.,;:\s@\"]+
      (\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))
      @((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}
      \.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+
      [a-zA-Z]{2,}))$ ///

    unless name
      FlashMessages.sendError "Indtast et brugernavn"
      error = 1

    unless email and email.match(pattern)
      FlashMessages.sendError "Ugyldig email adresse"
      error = 1

    unless password and password is password2
      FlashMessages.sendError "Adgangskode er ugyldig eller ikke ens"
      error = 1  

    if error
      return

    Accounts.createUser
      username: email
      password: password
      email: email
      profile: { name: name }
    , (err) ->
      if err?
        console.log err.error
        if err.error == 403
          FlashMessages.sendError
            "E-mail-adresse eller brugernavn allerede registreret"
        else
          FlashMessages.sendError "Kunne ikke oprette bruger"
          console.log err
      else
        Meteor.users.update
        Router.go 'lobby'
        FlashMessages.sendSuccess "Bruger oprettet"
