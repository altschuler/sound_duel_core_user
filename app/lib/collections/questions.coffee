# app/client/lib/collections/questions.coffee

@Questions = new Meteor.Collection 'questions'

# permission

Questions.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'questions', ->
    Questions.find() # TODO
