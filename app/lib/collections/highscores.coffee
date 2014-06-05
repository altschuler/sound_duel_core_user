# app/client/lib/collections/highscores.coffee

@Highscores = new Meteor.Collection 'highscores'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'highscores', ->
    Highscores.find() # TODO
