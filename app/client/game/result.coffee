# app/client/game/result.coffee

# methods

# get the current player's role
currentPlayerRole = ->
  if currentPlayerId() is currentChallenge().challengerId
    'challenger'
  else
    'challengee'


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
    opponent = null
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

    game.state isnt 'init'

  declined: ->
    Games.findOne(currentChallenge().challengeeGameId).state is 'declined'

  result: ->
    highscore = null

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
    challenge = currentChallenge()
    return unless Games.findOne(challenge.challengeeGameId).state is 'finished'

    challengeeHighscore = Highscores.findOne
      gameId: challenge.challengeeGameId
    challengerHighscore = Highscores.findOne
      gameId: challenge.challengerGameId

    if challengeeHighscore.score > challengerHighscore.score
      winner = 'challengee'
    else if challengeeHighscore.score < challengerHighscore.score
      winner = 'challenger'
    else
      winner = 'tie'

    if winner is 'tie'
      "Wow, der ble uafgjort!"
    else if currentPlayerRole() is winner
      "Tillykke, du har vundet!"
    else
      "Ugh, du har tabt!"


# events

Template.result.events
  'click a#restart': ->
    Session.set 'gameId', ''
    Router.go 'lobby'
