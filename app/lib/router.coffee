# app/lib/router.coffee

# client

if Meteor.isClient
  Meteor.Router.add
    '/': 'lobby'

    '/games/:_id/play':
      to: 'play'
      and: (id) ->
        Session.set 'gameId', id
    '/games/:_id/result':
      to: 'result'
      and: (id) ->
        Session.set 'gameId', id

    '/highscores': 'highscores'

    '/logout':
      to: 'lobby'
      and: ->
        localStorage.removeItem 'playerId'

# server

# if Meteor.isServer
#   Meteor.Router.add
#     '/games/:_id.json': (id) ->
#       Games.findOne id
