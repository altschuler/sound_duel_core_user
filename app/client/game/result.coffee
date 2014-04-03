# app/client/game/result.coffee

# methods

currentPlayerRole = ->
  isChallenger = currentPlayerId() is currentChallenge().challengerId
  isChallengee = currentPlayerId() is currentChallenge().challengeeId

  # check for error
  if isChallenger and isChallengee
    throw new Meteor.Error 500, 'Cannot be challenger and challengee'

  # return the players role
  if isChallenger
    'challenger'
  else if isChallengee
    'challengee'


# helpers

Template.result.helpers
  result: ->
    highscore = Highscores.findOne { gameId: currentGame()._id }
    {
      score: highscore.score
      ratio: "#{highscore.correctAnswers}/#{numberOfQuestions()}"
    }

  challenge: -> currentChallenge()?

Template.challenge.helpers
  opponent: ->
    opponent = Meteor.users.findOne currentChallenge().challengeeId
    opponent.username

  answered: ->
    game = Games.findOne currentChallenge().challengeeGameId

    if game.state is 'finished' and currentPlayerRole() is 'challenger'
      Challenges.update currentChallenge()._id, $set: { notified: true }

    game.state is 'finished'

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

  winner: ->
    unless Games.findOne(currentChallenge().challengeeGameId).state is 'finished'
      return

    challengeeHighscore = Highscores.findOne
      gameId: currentChallenge().challengeeGameId
    challengerHighscore = Highscores.findOne
      gameId: currentChallenge().challengerGameId

    if challengeeHighscore.score > challengerHighscore.score
      winner = 'challengee'
    else if challengeeHighscore.score < challengerHighscore.score
      winner = 'challenger'
    else
      winner = 'tie'

    if winner is 'tie'
      "Wow, du bundet!"
    else if currentPlayerRole() is winner
      "Tillykke, du har vundet!"
    else
      "Ugh, du har tabt!"


# events

Template.result.events
  'click a#restart': ->
    Session.set 'gameId', ''
    Router.go 'lobby'
