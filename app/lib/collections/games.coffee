# app/client/lib/collections/games.coffee

@Games = new Meteor.Collection 'games'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'games', ->
    Games.find() # TODO
