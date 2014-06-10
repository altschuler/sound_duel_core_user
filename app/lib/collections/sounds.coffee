# app/client/lib/collections/sounds.coffee

@Sounds = new Meteor.Collection 'sounds'

# permission

Sounds.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'sounds', ->
    Sounds.find() # TODO
