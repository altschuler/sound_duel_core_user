# app/client/game/play.coffee

# methods

# binds audio element progression with progress bar
bindAssetProgress = (asset) ->
  $(asset).bind 'timeupdate', ->
    percent = (this.currentTime * 100) / this.duration
    value = (currentGame().pointsPerQuestion * (100 - percent)) / 100

    # update progress bar width depending on audio progress
    $('#asset-bar').attr 'style', "width: #{100 - percent}%"
    $('#asset-bar').text Math.floor value

# start playback of audio element
playAsset = (asset, callback) ->
  # bind audio progress
  bindAssetProgress currentAsset()
  # play asset
  asset.play()

  # check that the audio element is playing, if not deal with it
  setTimeout( ->
    if asset.paused
      notify
        title:   "Gør dig klar!"
        confirm: "Spil!"
    else
      $('.alternative').prop 'disabled', false
      callback asset if callback
  , 1000)

answerQuestion = (answer) ->
  # pause asset
  currentAsset().pause()

  # calculate points
  points = parseInt($('#asset-bar').text(), 10)
  # if asset hasn't started, max points
  if isNaN points then points = currentGame().pointsPerQuestion

  # update current game object
  Games.update currentGame()._id,
    $addToSet:
      answers:
        questionId: currentQuestion()._id
        answer: answer
        points: points
    $inc:
      currentQuestion: 1

  # check for new question
  # when more: bind progress, play audio and enable alternatives
  unless currentGameFinished()
    setTimeout ->
      playAsset currentAsset()
    , 500
  # when no questions end game and show result
  else
    Meteor.call 'endGame', currentPlayerId(), (error, result) ->
      Meteor.Router.to "/games/#{currentGameId()}/result"

randomSegment = (sound) ->
  unless sound.segments?.length then return null
  sound.segments[Math.floor(Math.random() * sound.segments.length)]


# helpers

Template.assets.helpers
  segments: ->
    questions = currentGame().questionIds.map (id) -> Questions.findOne id
    sounds = questions.map (question) -> Sounds.findOne question.soundId

    # wrap the sound segments with id
    sounds.map (sound) ->
      id:   sound._id
      path: "/audio/#{randomSegment(sound)}"

Template.game.helpers
  currentQuestion: ->
    currentQuestion = (currentGame().currentQuestion + 1)
    "#{currentQuestion}/#{numberOfQuestions()}"

  alternatives: ->
    unless currentGameFinished()
      currentQuestion().alternatives


# rendered

Template.game.rendered = ->
  # ask if player is ready when page is loaded
  if currentGame().state is 'init' #
    # prompt to start game
    notify
      title:   "Gør dig klar!"
      content: "Når du er klar til at spille, skal du trykke 'Starte spill!'"
      cancel:  "Gå tilbake"
      confirm: "Starte spill!"

  # disable alternatives if asset is paused
  if not currentGameFinished() and currentAsset().paused
    $('.alternative').prop 'disabled', true


# events

Template.play.events
  # play asset if player is ready
  'click #popup-confirm': (event) ->
    playAsset currentAsset(), (element) ->
      Games.update currentGameId(),
        $set: { state: 'inprogress' }

  # go home if player not ready
  'click #popup-cancel': (event) ->
    Meteor.Router.to '/'
    Session.set 'gameId', ''
    # TODO: remove orphaned game

  # answer question with clicked alternative
  'click .alternative': (event) ->
    answerQuestion $(event.target).attr('id')
