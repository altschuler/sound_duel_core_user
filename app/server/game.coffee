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
      $addToSet:
        highscoreIds: highscoreId

    gameId

  endGame: (playerId) ->
    gameId = Meteor.users.findOne(playerId).gameId

    for q in Games.findOne(gameId).questionIds
      Questions.update q, $set: { answerable: false }

    Games.update gameId, { $set: { finished: true } }

    Meteor.users.update playerId, { $set: { gameId: undefined } }
