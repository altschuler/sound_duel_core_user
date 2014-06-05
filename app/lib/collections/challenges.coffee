# app/client/lib/collections/challenges.coffee

@Challenges = new Meteor.Collection 'challenges'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'challenges', ->
    Challenges.find() # TODO
