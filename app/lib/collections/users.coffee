# app/client/lib/collections/users.coffee

# permission
# TODO
Meteor.users.allow
  insert: (userId, doc) ->
    true

  update: (userId, doc, fields, modifier) ->
    true

  remove: (userId, doc) ->
    false


# publish

if Meteor.isServer
  #TODO: do not publish all facebook data. maybe none
  Meteor.publish 'users', ->
    Meteor.users.find()
