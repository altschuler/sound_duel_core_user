# app/client/lobby/lobby.coffee

# methods

onlinePlayers = ->
  playerId = Session.get('playerId') or currentPlayerId()
  Meteor.users.find(
    _id: { $ne: playerId }
    'online': true
  )

handleUsernameError = (error) ->
  $('button#new-game').prop 'disabled', true
  if error.error is 409
    Session.set 'usernameError', error.reason
  else
    Session.set 'usernameError', 'Ops! Something bad happened.'
    throw error

# helpers

Template.lobby.helpers
  username: ->
    if Meteor.user().profile
      Meteor.user().profile.name
    else
      Meteor.user().emails[0].address

  usernameError: -> Session.get 'usernameError'

  usernameDisabled: ->
    'disabled' if currentPlayer()?

  newGameDisabled: ->
    'disabled' unless currentPlayer()?

Template.players.helpers
  onlinePlayers: onlinePlayers

  waitingPlayers: ->
    count = onlinePlayers().count()
    if count is 0
      "Ingen spillere online"
    else if count is 1
      "1 spiller online:"
    else
      "#{count} spillere der er online:"
