# app/server/game.coffee

# methods

Meteor.methods
  keepalive: (playerId) ->
    # check playerId
    return unless playerId

    Meteor.users.update playerId,
      $set:
        online: true
        lastKeepalive: (new Date()).getTime()

  newGame: (playerId) ->
    # TODO: avoid getting the same questions
    questions = Questions.find({}, { limit: 5 }).fetch()

    gameId = Games.insert
      pointsPerQuestion: CONFIG.POINTS_PER_QUESTION
      questionIds: questions.map (q) -> q._id
      currentQuestion: 0
      answers: []

    highscoreId = Highscores.insert
      gameId: gameId

    Meteor.users.update playerId,
      $set:
        gameId: gameId

    gameId

  endGame: (playerId) ->
    gameId = Meteor.users.findOne(playerId).gameId
    game = Games.findOne(gameId)

    # calculate score
    points = 0
    correct = 0
    for a in game.answers
      q = Questions.findOne(a.questionId)
      if a.answer is q.correct
        correct++
        points += a.points

    # update highscore
    highscoreId = Highscores.findOne
      gameId: gameId

    Highscores.update highscoreId,
      $set:
        corrects: correct
        score: points


    for q in game.questionIds
      Questions.update q, { $set: { answerable: false } }

    Games.update gameId, { $set: { finished: true } }

    Meteor.users.update playerId,
      $set: { gameId: undefined }
      $addToSet: { highscoreIds: highscoreId }
