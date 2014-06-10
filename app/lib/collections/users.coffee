# app/client/lib/collections/users.coffee

# permission

Meteor.users.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  #TODO: do not publish all facebook data. maybe none
  Meteor.publish 'users', ->
    Meteor.users.find()
