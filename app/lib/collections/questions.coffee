# app/client/lib/collections/questions.coffee

@Questions = new Meteor.Collection 'questions'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'questions', ->
    Questions.find() # TODO
