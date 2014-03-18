# app/client/game/result.coffee

# methods

playerRole = ->
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
    game.state is 'finished'

  result: ->
    role = playerRole()
    if role is 'challenger'
      highscore = Highscores.findOne
        gameId: currentChallenge().challengeeGameId
    else
      highscore = Highscores.findOne
        gameId: currentChallenge().challengerGameId
    {
      score: highscore.score
      ratio: "#{highscore.correctAnswers}/#{numberOfQuestions()}"
    }


# events

Template.result.events
  'click a#restart': ->
    Session.set 'gameId', ''
    Meteor.Router.to '/'
