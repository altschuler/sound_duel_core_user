# app/client/game/play.coffee

# methods

# binds audio element progression with progress bar
bindAssetProgress = (asset) ->
  $(asset).bind 'timeupdate', ->
    percent = (this.currentTime * 100) / this.duration
    Session.set 'gameProgress', percent
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
      callback asset if callback?
  , 1000)

answerQuestion = (answer) ->
  # pause asset
  currentAsset().pause()

  # calculate points
  points = parseInt($('#asset-bar').text(), 10)
  # if asset hasn't started, max points
  if isNaN points then points = currentGame().pointsPerQuestion

  # update current game object
  Games.update currentGameId(),
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
    setTimeout (-> playAsset currentAsset()), 500
  # when no questions end game and show result
  else
    Meteor.call 'endGame', currentPlayerId(), (error, result) ->
      Router.go 'game', _id: currentGameId(), action: 'result'

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

  progressBarColor: ->
    progress = Session.get 'gameProgress'
    if progress is 100
      ''
    else if progress > 66
      'progress-bar-danger'
    else if progress > 33
      'progress-bar-warning'
    else
      'progress-bar-success'

  alternatives: ->
    unless currentGameFinished()
      currentQuestion().alternatives


# rendered

Template.game.rendered = ->
  # ask if player is ready when page is loaded
  # and prompt to start game
  notify
    title:   "Gør dig klar!"
    content: "Når du er klar til at spille, skal du trykke 'Start spillet!'"
    cancel:  "Gå tilbage"
    confirm: "Start spillet!"

  # disable alternatives if asset is paused
  if not currentGameFinished() and currentAsset().paused
    $('.alternative').prop 'disabled', true


# events

Template.play.events
  # answer question with clicked alternative
  'click .alternative': (event) ->
    $('.alternative').prop 'disabled', true
    answerQuestion event.target.id

Template.popup.events
  # play asset if player is ready
  'click #popup-confirm': (event) ->
    text = $('#popup-confirm').text().replace /^\s+|\s+$/g, ""
    switch text
      when "Start spillet!"
        Games.update currentGameId(), $set: {state: 'inprogress'}, (error) ->
          playAsset currentAsset()
        Meteor.users.update currentPlayerId(), $set:
          'profile.currentGameId': currentGameId()
      when "Spil!"
        playAsset currentAsset()

  # go to lobby if player not ready
  'click #popup-cancel': (event) ->
    # TODO: remove orphaned game
    Games.update currentGameId(), $set: { state: 'declined' }
    Session.set 'gameId', ''
    Router.go 'lobby'
