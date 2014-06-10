# app/client/session/signup.coffee

# events
Template.signup.events
  'click #signup': (evt) ->
    evt.preventDefault()
    error = false

    name = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
    email = "#{$('input#email').val()}".replace /^\s+|\s+$/g, ""
    password = "#{$('input#password').val()}".replace /^\s+|\s+$/g, ""
    password2 = "#{$('input#password2').val()}".replace /^\s+|\s+$/g, ""

    unless name
      FlashMessages.sendError "Indtast et brugernavn"
      error = true

    unless validateEmail email
      FlashMessages.sendError "Ugyldig email adresse"
      error = true

    unless password and password is password2
      FlashMessages.sendError "Adgangskode er ugyldig eller ikke ens"
      error = true

    return if error

    Accounts.createUser
      username: email
      password: password
      email: email
      profile: { name: name }
    , (err) ->
      if err?
        if err.error == 403
          FlashMessages.sendError "E-mail-adresse eller"+
          "brugernavn allerede registreret"
        else
          FlashMessages.sendError "Kunne ikke oprette bruger"
          console.log err
      else
        Router.go 'lobby'
        FlashMessages.sendSuccess "Bruger oprettet"
