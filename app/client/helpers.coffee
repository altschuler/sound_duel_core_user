# app/client/helpers.coffee

@goHome = ->
  Meteor.Router.to '/'
  location.reload()

@forcePlayAudio = (audioSelector, callback) ->
  playInterval = setInterval( ->
    $assets = $(audioSelector)
    # Wait for the first audio asset.
    if $assets.length > 0
      assetElement = $assets.get(0)
      unless assetElement.paused
        clearInterval playInterval
        callback assetElement
      else
        assetElement.play()
  , 500) # TODO: Make 250, less of a magic number.

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
  console.log highscore
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
  id = Session.get 'playerId'
  # lazy init
  # unless id and Meteor.users.findOne id
  #   id = Meteor.users.insert
  #     username: ''
  #   Meteor.users.update id,
  #     $set: { 'profile.online': true }
  #   Session.set 'playerId', id

  id

@currentPlayer = ->
  Meteor.users.findOne currentPlayerId()

@newPlayer = (name, callback) ->
  Meteor.users.insert username: name, (error, id) ->
    console.log "id: #{id}"
    console.log error

    unless error
      Session.set 'playerId', id

      callback()
    else
      Meteor.Router.to '/', alert: "wow"

@onlinePlayers = ->
  Meteor.users.find
    _id: { $ne: currentPlayerId() }
    'profile.online': true
  .fetch()

Handlebars.registerHelper 'onlinePlayers', onlinePlayers
