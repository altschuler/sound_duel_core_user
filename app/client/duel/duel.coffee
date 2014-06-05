# app/client/duel/duel.coffee

# methods

acceptedEmail = (email) ->
  validateEmail(email) and email not in currentPlayerEmails()


# events

Template.duel.events
  'click .js-start-game': (event) ->
    event.preventDefault()
    email = "#{$('.js-challenge-email').val()}".replace /^\s+|\s+$/g, ""

    if acceptedEmail email
      startGame { challengeeEmail: email }
      # Meteor.call 'newGame', currentPlayerId(),
      # {challengeeEmail: $email.val()}, (error, result) ->
      #   Router.go 'game', _id: result.gameId, action: 'play'

  'keyup .js-challenge-email': (event) ->
    email = "#{$('.js-challenge-email').val()}".replace /^\s+|\s+$/g, ""

    $('.js-start-game').attr 'disabled', not acceptedEmail email
