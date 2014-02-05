# app/client/helpers.coffee

@goHome = ->
  Meteor.Router.to '/'
  location.reload()

@forcePlayAudio = (audioSelector, callback) ->
  playInterval = setInterval( ->
    $asset = $(audioSelector)

    # Wait for the first audio asset.
    if $asset.length > 0
      assetElement = $asset[0]

      unless assetElement.paused
        clearInterval playInterval
        callback assetElement
      else
        console.log "play element: #{assetElement}"
        assetElement.play()

  , 750) # TODO: Make 250, less of a magic number.

@currentGameId = ->
  id = Session.get 'gameId'
  if id then id else goHome()

@currentGame = ->
  game = Games.findOne currentGameId()
  unless game then goHome() else game

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion + 1 > numberOfQuestions()
  currentGame().finished or outOfQuestions

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
