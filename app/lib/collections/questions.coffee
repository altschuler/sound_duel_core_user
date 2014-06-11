# app/client/lib/collections/questions.coffee

@Questions = new Meteor.Collection 'questions'

allowedFields =
  correctAnswer: 0

# permission

Questions.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'currentQuizQuestions', (gameId) ->
    game = Games.findOne gameId
    return [] unless game?

    quiz = Quizzes.findOne game.quizId
    return [] unless quiz?

    Questions.find
      _id: { $in: quiz.questionIds }
    ,
      fields: allowedFields
