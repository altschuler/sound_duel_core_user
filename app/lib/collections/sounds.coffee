# app/client/lib/collections/sounds.coffee

@Sounds = new Meteor.Collection 'sounds'

# permission

Sounds.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'currentQuizSounds', (gameId) ->
    game = Games.findOne gameId
    return [] unless game?

    quiz = Quizzes.findOne game.quizId
    return [] unless quiz?

    questions = Questions.find _id: { $in: quiz.questionIds }

    Sounds.find _id: { $in: questions.map (q) -> q.soundId }
