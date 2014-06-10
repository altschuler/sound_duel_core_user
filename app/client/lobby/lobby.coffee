# app/client/lobby/lobby.coffee

# helpers

Template.lobby.helpers
  game_name: -> "Marco's Crazy VM spil"

Template.lobbyLoggedIn.helpers
  username: ->
    if Meteor.user().profile?
      Meteor.user().profile.name
    else
      ""

#events

Template.lobbyLoggedIn.events
  'click .js-start-game': (event) ->
    startGame({})
