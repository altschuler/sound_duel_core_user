# app/client/lib/collections/highscores.coffee

@Highscores = new Meteor.Collection 'highscores'

# permission

Highscores.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'highscores', ->
    Highscores.find()

  Meteor.publish 'currentQuizHighscores', (gameId) ->
    game = Games.findOne gameId
    return [] unless game?

    Highscores.find quizId: game.quizId
