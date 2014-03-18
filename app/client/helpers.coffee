# app/client/helpers.coffee#

# methods

# helper method for failing gracefully when required value is null
failIfNull = (value=null, msg) ->
  # if given value is null, route to home screen and throw error
  unless value?
    Meteor.Router.to '/'
    throw new Error msg
  # else, return the value
  else
    value


# helpers

# show popup dialog with text and options
@notify = ({title, content, cancel, confirm}) ->
  # set text or hide if not set
  # title
  $('#popup-title').text title
  # body
  if content
    $('#popup-content').text content
  else
    $('#popup-content').hide()
  # cancel button
  if cancel then $('#popup-cancel').text cancel else $('#popup-cancel').hide()
  # confirm button
  $('#popup-confirm').text confirm

  # show dialog
  $('#popup').modal()

@currentPlayerId = ->
  localStorage.getItem 'playerId'

@currentPlayer = ->
  Meteor.users.findOne currentPlayerId()

@currentGameId = ->
  failIfNull Session.get('gameId'), 'Session gameId not set'

@currentGame = ->
  failIfNull Games.findOne(currentGameId()),
    "Current game not found (id: #{currentGameId()})"

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion >= numberOfQuestions()
  outOfQuestions or currentGame().state is 'finished'

@currentChallenge = ->
  c =  Challenges.findOne { challengerGameId: currentGameId() }
  c ?= Challenges.findOne { challengeeGameId: currentGameId() }
  c

@currentChallengeId = ->
  currentChallenge()._id

@currentHighscore = ->
  failIfNull Highscores.findOne({ gameId: currentGameId() }),
    'Current game has no highscore'

@currentQuestionId = ->
  idx = currentGame().currentQuestion
  currentGame().questionIds[idx]

@currentQuestion = ->
  failIfNull Questions.findOne(currentQuestionId()),
    "Current question not found (id: #{currentQuestionId()})"

@numberOfQuestions = ->
  currentGame().questionIds.length

@currentAsset = ->
  $(".asset##{currentQuestion().soundId}")[0]
