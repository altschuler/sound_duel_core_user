# app/lib/router.coffee

# client

if Meteor.isClient
  Meteor.Router.add
    '/': 'lobby'

    '/games/:_id/play':
      to: 'play'
      and: (id) ->
        Session.set 'game_id', id
    '/games/:_id/result':
      to: 'result'
      and: (id) ->
        Session.set 'game_id', id


# server

# if Meteor.isServer
#   Meteor.Router.add
#     '/games/:id.json': (id) ->
#       Games.findOne id
