# app/client/lib/collections/sounds.coffee

@Sounds = new Meteor.Collection 'sounds'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'sounds', ->
    Sounds.find() # TODO
