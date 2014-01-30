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
      if not assetElement.paused
        clearInterval playInterval
        callback(assetElement)
      else
        assetElement.play()
  , 500) # TODO: Make 250, less of a magic number.

@currentGameId = ->
  id = Session.get 'gameId'
  unless id then goHome() else id

@currentGame = ->
  game = Games.findOne currentGameId()
  unless game then goHome() else game

@currentHighscore = ->
  Highscores.findOne
    gameId: currentGameId()

@currentQuestionId = ->
  idx = currentGame().currentQuestion
  currentGame().questionIds[idx]

@currentQuestion = ->
  Questions.findOne currentQuestionId()

@numberOfQuestions = ->
  currentGame().questionIds.length

@currentAsset = ->
  $(".asset##{currentQuestion().soundId}")[0]

@currentGuest = ->
  Session.get 'guest'

# WIP
@currentPlayerId = ->
  id = Session.get 'playerId'
  unless id and Meteor.users.findOne id
    id = Meteor.users.insert
      username: ''
      'profile.online': true
    Session.set 'playerId', id
  console.log id
  id

@currentPlayer = ->
  Meteor.users.findOne currentPlayerId()

@onlinePlayers = ->
  Meteor.users.find
    _id: { $ne: Meteor.userId() }
    'profile.online': true
  .fetch()

Handlebars.registerHelper 'onlinePlayers', onlinePlayers
