# app/client/single/single.coffee

# methods

# helpers

# Template.single.helpers
#   username: ->
#     Meteor.user().profile.name

#   usernameError: -> Session.get 'usernameError'

#   usernameDisabled: ->
#     'disabled' if currentPlayer()?

#   newGameDisabled: ->
#     'disabled' unless currentPlayer()?

# events

Template.single.events
  'click .js-start-game': (event) ->
    Meteor.call 'newGame', currentPlayerId(), {}, (error, result) ->
      Router.go 'game', _id: result.gameId, action: 'play'
