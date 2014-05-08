# app/client/game/result.coffee

# methods

currentPlayerRole = ->
  if currentPlayerId() is currentChallenge().challengerId
    'challenger'
  else
    'challengee'

winnerRole = ->
  challenge = currentChallenge()
  return unless Games.findOne(challenge.challengeeGameId).state is 'finished'

  challengeeHighscore = Highscores.findOne
    gameId: challenge.challengeeGameId
  challengerHighscore = Highscores.findOne
    gameId: challenge.challengerGameId

  if challengeeHighscore.score > challengerHighscore.score
    'challengee'
  else if challengeeHighscore.score < challengerHighscore.score
    'challenger'
  else
    'tie'


# helpers

Template.result.helpers
  result: ->
    highscore = Highscores.findOne gameId: currentGame()._id
    {
      score: highscore.score
      ratio: "#{highscore.correctAnswers}/#{numberOfQuestions()}"
    }

  isChallenge: -> currentChallenge()?

Template.challenge.helpers
  opponent: ->
    if currentPlayerRole() is 'challengee'
      opponent = Meteor.users.findOne currentChallenge().challengerId
    else
      opponent = Meteor.users.findOne currentChallenge().challengeeId

    opponent.username

  answered: ->
    game = Games.findOne currentChallenge().challengeeGameId

    # so challenger wont be notified of a seen result
    if game.state is 'finished' and currentPlayerRole() is 'challenger'
      Challenges.update currentChallenge()._id, $set: { notified: true }

    game.state is 'finished'

  declined: ->
    Games.findOne(currentChallenge().challengeeGameId).state is 'declined'

  result: ->
    if currentPlayerRole() is 'challenger'
      highscore = Highscores.findOne
        gameId: currentChallenge().challengeeGameId
    else
      highscore = Highscores.findOne
        gameId: currentChallenge().challengerGameId

    {
      score: highscore.score
      ratio: "#{highscore.correctAnswers}/#{numberOfQuestions()}"
    }

  isWinner: ->
    winner = winnerRole()
    return unless winner

    if winner is 'tie'
      "alert alert-warning"
    else if winner is currentPlayerRole()
      "alert alert-success"
    else
      "alert alert-danger"

  winner: ->
    winner = winnerRole()
    return unless winner

    if winner is 'tie'
      "Wow, der ble uafgjort!"
    else if winner is currentPlayerRole()
      "Tillykke, du har vundet!"
    else
      "Ugh, du har tabt!"


# events

Template.result.events
  'click a#restart': ->
    Session.set 'gameId', ''
    Router.go 'lobby'
