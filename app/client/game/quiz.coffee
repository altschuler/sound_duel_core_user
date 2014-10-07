# app/client/game/play.coffee

# methods

answerQuestion = (answer) ->
  # pause asset
  audioPlayer().pause()
  $audioPlayer().unbind('timeupdate')

  # calculate points
  # TODO: move points calc to server
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

  question_counter = Session.get('currentQuestion')

  # If we answered the last question
  if question_counter + 1 == currentQuiz().questionIds.length
    Meteor.call 'endGame', currentGameId(), (error, result) ->
      Router.go 'game', _id: currentGameId(), action: 'result'
  else
    # otherwise go to the next question
    Session.set('currentQuestion', question_counter + 1)
    Template.question.startQuestion()


# helpers

$audioPlayer = -> $('[data-sd-audio-player]')
audioPlayer = -> $audioPlayer()[0]

Template.assets.helpers

  loadSound: ->
    audioPlayer().src = currentAudioSrc()
    audioPlayer().load()

  # Play <audio> element with 0.3 seconds of silence,
  # in order to workaround iOS limitations on HTML5 audio playback
  playSilence: ->
    audioPlayer().src = '/audio/silence.mp3'
    audioPlayer().play()

    # Load the real question sound after having played the silent audio clip
    audioPlayer().addEventListener('ended', @loadSound, false)

  # start playback of audio element
  playAsset: (callback) ->
    # bind audio progress
    @bindAssetProgress()
    # play
    audioPlayer().play()

  # binds audio element progression with progress bar
  bindAssetProgress: ->
    console.log 'bindAssetProgress() called'
    $audioPlayer().bind 'timeupdate', ->
      console.log 'timeupdate eventListener called'
      percent = (this.currentTime * 100) / this.duration
      Session.set 'gameProgress', percent
      value = (currentGame().pointsPerQuestion * (100 - percent)) / 100

      # update progress bar width depending on audio progress
      $('#asset-bar')
        .attr('style', "width: #{100 - percent}%")
        .text Math.floor(value) + " points"


Template.question.helpers
  currentQuestion: -> currentQuiz().name

  currentQuestionNumber: -> currentGame().currentQuestion + 1

  numberOfQuestions: -> numberOfQuestions()

  alternatives: ->
    currentQuestion().alternatives

  progressBarColor: ->
    percent = Session.get 'gameProgress'
    if percent is 100
      ''
    else if percent > 66
      'percent-bar-danger'
    else if percent > 33
      'progress-bar-warning'
    else
      'progress-bar-success'

  enabledAnswers: -> # TODO:
    predefined: yes
    freeText: yes

Template.question.startQuestion = ->
  # Reset progress bar
  $('#asset-bar')
    .attr('style', "width: 100%")
    .text Math.floor(currentQuiz().pointsPerQuestion)

  $('.alternative').prop 'disabled', false
  Template.assets.playAsset()

# **iOS**: Ensure that sound is started
Template.question.ensurePlaying = ->
  Template.question.startQuestion()

# rendered
Template.question.rendered = ->
  Template.question.startQuestion()

# events
Template.question.events
  # answer question with predefined alternative
  'click .alternative-predefined': (event) ->
    $('.alternative').prop 'disabled', true
    answerQuestion event.target.id

  # answer question with free text input
  'click .alternative-free-text': (event) ->
    answer = $('.free-text > input').val()
    alert "Free text not yet implemented\nAnswer was '#{answer}'" # TODO:
