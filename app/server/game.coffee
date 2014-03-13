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


  newPlayer: (name) ->
    # username taken
    if Meteor.users.find({ username: name }).fetch().length > 0
      throw new Meteor.Error 409, 'Username taken'

    id = Meteor.users.insert { username: name }

    Meteor.users.update id,
      $set:
        'profile.online': true
        'profile.highscoreIds': []
        'profile.challenges': []

    id


  newGame: (playerId, {challengeeId, answerChallengeId}) ->
    # cannot challange and answer at same time
    if challengeeId and answerChallengeId
      throw new Meteor.Error

    if answerChallengeId
      gameId = Challenges.findOn(eanswerChallengeId).challengeeGameId
    else
      # TODO: avoid getting the same questions
      questions = Questions.find({}, { limit: 5 }).fetch()

      gameId = Games.insert
        questionIds: questions.map (q) -> q._id
        pointsPerQuestion: CONFIG.POINTS_PER_QUESTION
        currentQuestion: 0
        answers: []
        state: 'init'

    if challengeeId
      # TODO: avoid getting the same questions
      challengeQuestions = Questions.find({}, { limit: 5 }).fetch()

      challengeeGameId = Games.insert
        questionIds: challengeQuestions.map (q) -> q._id
        pointsPerQuestion: CONFIG.POINTS_PER_QUESTION
        currentQuestion: 0
        answers: []
        state: 'init'

      challengeId = Challenges.insert
        challengerId: playerId
        challengeeId: challengeeId
        challengerGameId: gameId
        challengeeGameId: challengeeGameId

      Meteor.users.update challengeeId,
        $addToSet: { 'profile.challenges': challengeId }

    Meteor.users.update playerId, $set: { gameId: gameId }
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
    highscoreId = Highscores.insert
      gameId: gameId
      playerId: playerId
      correctAnswers: correctAnswers
      score: score

    for q in game.questionIds
      Questions.update q, { $set: { answerable: false } }

    Games.update gameId, { $set: { state: 'finished' } }

    Meteor.users.update playerId,
      $set: { 'profile.gameId': undefined }
      $addToSet: { 'profile.highscoreIds': highscoreId }
