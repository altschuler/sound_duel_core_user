# app/client/helpers.coffee

@goHome = ->
  Meteor.Router.to '/'
  location.reload()

@forcePlayAudio = (audioSelector, callback) ->
  playInterval = setInterval ->
    $assets = $(audioSelector)
    # Wait for the first audio asset.
    if $assets.length > 0
      assetElement = $assets.get(0)
      if not assetElement.paused
        clearInterval playInterval
        callback(assetElement)
      else
        assetElement.play()
  , 500 # TODO: Make 250, less of a magic number.

@currentGameId = ->
  id = Session.get 'gameId'
  unless id then goHome() else id

@currentGame = ->
  game = Games.findOne currentGameId()
  unless game then goHome() else game

@currentQuestionId = ->
  idx = currentGame().currentQuestion
  currentGame().questionIds[idx]

@currentQuestion = ->
  Questions.findOne currentQuestionId()

@currentAsset = ->
  $(".asset##{currentQuestion().soundId}")[0]

@numberOfQuestions = ->
  currentGame().questionIds.length

@currentGuest = ->
  Session.get 'guest'

@onlinePlayers = ->
  Meteor.users.find
    _id: { $ne: Meteor.userId() }
    'profile.online': true
  .fetch()

Handlebars.registerHelper 'onlinePlayers', onlinePlayers

# @currentHighscore = ->
#   Highscores.findOne
#     gameId: currentGameId()
