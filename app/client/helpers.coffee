# app/client/helpers.coffee

@goHome = ->
  Meteor.Router.to '/'
  location.reload()

@currentGameId = ->
  id = Session.get 'gameId'
  if id then id else goHome()

@currentGame = ->
  game = Games.findOne currentGameId()
  unless game then goHome() else game

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion + 1 > numberOfQuestions()
  currentGame().state is 'finished' or outOfQuestions

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
  Session.get 'playerId'

@currentPlayer = ->
  Meteor.users.findOne currentPlayerId()

@newPlayer = (name, callback) ->
  unless name
    alert "Brugernavn ikke satt"
  else
    id = Meteor.users.insert { username: name }, (error, id) ->
      if error
        console.log error

        Meteor.Router.to '/'

        if error.error is 409
          alert "Brugernavn taget"
        else
          alert error.message

        callback error, id
      else
        Session.set 'playerId', id
        Meteor.users.update id, { $set: { 'profile.online': true } }

      callback error, id

@onlinePlayers = ->
  Meteor.users.find
    _id: { $ne: currentPlayerId() }
    'profile.online': true
  .fetch()

Handlebars.registerHelper 'onlinePlayers', onlinePlayers
