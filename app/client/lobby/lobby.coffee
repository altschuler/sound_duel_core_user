# app/client/lobby/lobby.coffee

# helpers

Template.lobby.helpers
  disabled: ->
    if not currentGuest() or currentGuest == '' then 'disabled="disabled"'

Template.players.helpers
  waiting: ->
    count = onlinePlayers().length
    if count == 0
      "Ingen spillere online"
    else if count == 1
      "1 spiller online:"
    else
      "#{count} spillere der er online:"


# events

Template.lobby.events
  'keyup input#name': (event, template) ->
    if event.keyCode is 13
      $('#newGame').click()
    else
      # get name and remove ws
      name = template.find('input#name').value.replace /^\s+|\s+$/g, ""
      Session.set 'guest', name

  'click button#new-game': (event, template) ->
    Meteor.call 'newGame', Meteor.userId(), (error, result) ->
      Session.set 'gameId', result

      forcePlayAudio 'audio.asset:first', (element) ->
        Questions.update currentQuestionId(),
          $set: { 'answerable': true }

      Meteor.Router.to "/games/#{currentGameId()}/play"
