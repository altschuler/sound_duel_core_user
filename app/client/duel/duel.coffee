# app/client/duel/duel.coffee

# methods

validateEmail = (string) ->
  string != ''

# helpers

#Template.duel.helpers

# events

Template.duel.events
  'click .js-start-game': (event) ->
    $email = $('.js-challenge-email')
    if(validateEmail $email.val())
      Meteor.call 'newGame', currentPlayerId(),
      {challengeeEmail: $email.val()}, (error, result) ->
        Router.go 'game', _id: result.gameId, action: 'play'

  'keyup .js-challenge-email': (event) ->
    $this = $(event.target)
    $btn = $('.js-start-game')
    $btn.attr('disabled',not validateEmail $this.val())

# rendered

Template.duel.rendered = ->
  $('.form-inline').bind 'keydown', (e) ->
    if e.keyCode is 13
      e.preventDefault()