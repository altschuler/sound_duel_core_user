# app/client/helpers.coffee#

# methods

# helper method for failing gracefully when required value is null
failIfNull = (value=null, msg) ->
  # if given value is null, route to home screen and throw error
  unless value?
    Router.go 'lobby'
    throw new Error msg
  # else, return the value
  else
    value


# helpers

@currentPlayerEmails = ->
  Meteor.user().emails.map (c) -> c.address

@currentPlayerId = ->
  # Session.get 'playerId' or localStorage.getItem 'playerId'
  #localStorage.getItem 'playerId'
  Meteor.userId()

@currentPlayer = ->
  #Meteor.users.findOne currentPlayerId()
  Meteor.user()

@currentGameId = ->
  Session.get 'gameId'
  #failIfNull Session.get('gameId'), 'Session gameId not set'

@currentGame = ->
  Games.findOne(currentGameId())
  # failIfNull Games.findOne(currentGameId()),
  #   "Current game not found (id: #{currentGameId()})"

@currentQuizId = ->
  Session.get 'currentQuizId'
  #failIfNull Session.get('gameId'), 'Session gameId not set'

@currentQuiz = ->
  Quizzes.findOne(currentQuizId())
  # failIfNull Quizs.findOne(currentQuizId()),
  #   "Current game not found (id: #{currentQuizId()})"

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion >= numberOfQuestions()
  outOfQuestions or currentGame().state is 'finished'

@currentChallenge = -> # TODO: use or keyword
  c =  Challenges.findOne { challengerGameId: currentGameId() }
  c ?= Challenges.findOne { challengeeGameId: currentGameId() }
  c

@currentChallengeId = ->
  currentChallenge()._id

@currentHighscore = ->
  failIfNull Highscores.findOne({ gameId: currentGameId() }),
    'Current game has no highscore'

@currentQuestionId = ->
  idx = Session.get('currentQuestion')
  currentQuiz().questionIds[idx]

@currentQuestion = ->
  failIfNull Questions.findOne(currentQuestionId()),
    "Current question not found (id: #{currentQuestionId()})"

@numberOfQuestions = ->
  Quizzes.findOne(currentGame().quizId).questionIds.length

@currentAsset = ->
  $(".asset##{currentQuestion().soundId}")[0]
