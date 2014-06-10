# app/client/lib/collections/quizzes.coffee

@Quizzes = new Meteor.Collection 'quizzes'

# permission

Quizzes.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) ->
    true

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'quizzes', ->
    Quizzes.find() # TODO
