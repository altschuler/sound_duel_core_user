# app/client/helpers.coffee

@notify = ({title, content, cancel, confirm}) ->
  $('#popup-title').text title
  $('#popup-content').text content
  unless cancel
    $('#popup-cancel').hide()
  else
    $('#popup-cancel').text cancel
  $('#popup-confirm').text confirm
  $('#popup').modal()

@goHome = ->
  Meteor.Router.to '/'
  location.reload()

@currentGameId = ->
  id = Session.get 'gameId'
  unless id then goHome() else id

@currentGame = ->
  game = Games.findOne currentGameId()
  unless game then goHome() else game

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion >= numberOfQuestions()
  outOfQuestions or currentGame().state is 'finished'

@currentHighscore = ->
  highscore = Highscores.findOne
    gameId: currentGameId()
  unless highscore then goHome() else highscore

@currentQuestionId = ->
  idx = currentGame().currentQuestion
  currentGame().questionIds[idx]

@currentQuestion = ->
  Questions.findOne currentQuestionId()

@numberOfQuestions = ->
  currentGame().questionIds.length

@currentAsset = ->
  $(".asset##{currentQuestion().soundId}")[0]

@currentPlayerId = ->
  localStorage.getItem 'playerId'

@currentPlayer = ->
  Meteor.users.findOne currentPlayerId()
