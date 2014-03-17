# app/client/game/result.coffee

# helpers

Template.result.helpers
  result: ->
    {
      score: currentHighscore().score
      ratio: "#{currentHighscore().correctAnswers}/#{numberOfQuestions()}"
    }

  ischallenge: ->
    currentChallengeId()

Template.challenge.helpers
  answered: ->
    game = Games.findOne currentChallenge().challengeeGameId
    game.state is 'finished'

  result: ->
    highscore = Highscores.findOne
      gameId: currentChallenge().challengeeGameId
    {
      score: highscore.score
      ratio: "#{highscore.correctAnswers}/#{numberOfQuestions()}"
    }


# events

Template.result.events
  'click a#restart': ->
    Session.set 'gameId', ''
    Meteor.Router.to '/'
