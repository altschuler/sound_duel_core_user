# app/client/lib/collections/quizzes.coffee

@Quizzes = new Meteor.Collection 'quizzes'

# permission

Quizzes.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> true # TODO: testing

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'quizzes', ->
    today = new Date()
    Quizzes.find startDate: { $lt: today }

  Meteor.publish 'currentQuiz', (gameId) ->
    game = Games.findOne gameId
    return [] unless game?

    Quizzes.find game.quizId

  # TODO: testing
  Meteor.publish 'allQuizzes', ->
    Quizzes.find()
