# app/client/lib/collections/quizzes.coffee

@Quizzes = new Meteor.Collection 'quizzes'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'quizzes', ->
    Quizzes.find() # TODO
