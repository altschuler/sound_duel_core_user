# app/client/duel/duel.coffee

# methods

validateEmail = (string) ->
  string and jQuery.inArray(string,currentPlayerEmails()) == -1

# helpers

#Template.duel.helpers

# events

Template.duel.events
  'click .js-start-game': (event) ->
    event.preventDefault()
    $email = $('.js-challenge-email')
    if(validateEmail $email.val())
      startGame({challengeeEmail: $email.val()})
      # Meteor.call 'newGame', currentPlayerId(),
      # {challengeeEmail: $email.val()}, (error, result) ->
      #   Router.go 'game', _id: result.gameId, action: 'play'

  'keyup .js-challenge-email': (event) ->
    $this = $(event.target)
    $btn = $('.js-start-game')
    $btn.attr('disabled',not validateEmail $this.val())

# rendered

Template.duel.rendered = ->
  $('.form-inline').bind 'keydown', (e) ->
    if e.keyCode is 13
      e.preventDefault()