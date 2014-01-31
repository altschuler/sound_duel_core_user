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
    game = Games.findOne gameId

    # calculate score
    score = 0
    correctAnswers = 0
    for a in game.answers
      q = Questions.findOne a.questionId
      if a.answer is q.correctAnswer
        correctAnswers++
        score += a.points

    # update highscore
    highscoreId = Highscores.findOne gameId: gameId

    Highscores.update highscoreId,
      $set:
        correctAnswers: correctAnswers
        score: score


    for q in game.questionIds
      Questions.update q, { $set: { answerable: false } }

    Games.update gameId, { $set: { finished: true } }

    Meteor.users.update playerId,
      $set: { gameId: undefined }
      $addToSet: { highscoreIds: highscoreId }
