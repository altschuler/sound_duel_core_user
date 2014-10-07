# app/client/game/play.coffee

# constants
QuestionState =
  PLAY: "QuestionState.PLAY"
  SHARE: "QuestionState.SHARE"
  INITIAL: "QuestionState.INITIAL"
  COUNTDOWN: "QuestionState.COUNTDOWN"

  # Skip animation if spacebar is pressed
  # $('body').keyup (e) ->
  #   if e.keyCode == 32
  #     # user has pressed space
  #     Template.question.showQuestion()

startAnimation = ->
  Session.set 'gameProgress', 100
  Session.set 'questionState', QuestionState.COUNTDOWN

  # Setup variables
  i = 0
  texts = ['3', '2', '1', 'Start']

  $('.countdown').html texts[i]
  $('.countdown').removeClass('smaller')
  return if Session.get('currentQuestion') > 0

  # Change text on every animation iteration
  $(".countdown").bind("webkitAnimationIteration oAnimationIteration
    MSAnimationIteration animationiteration", ->
    i += 1
    $(this).text(texts[i])

    if texts[i].length > 2
      $(this).addClass('smaller')
    else
      $(this).removeClass('smaller')
  )

  # When the animation has ended show the questions and play the sound
  $(".countdown").bind("webkitAnimationEnd oAnimationEnd MSAnimationEnd
    animationend", ->
    Template.question.showQuestion()
    i = 0
  )

# methods
answerQuestion = (idx) ->
  # save last answer
  Session.set 'lastAnswer', idx

  # pause asset
  audioPlayer().pause()
  $audioPlayer().unbind('timeupdate')
  # If we answered the last question
  if idx >= currentQuiz().questionIds.length
    Meteor.call 'endGame', currentGameId(), (error, result) ->
      Router.go 'game', _id: currentGameId(), action: 'result'
  else
    # otherwise go to the next question
    Session.set 'currentQuestion', idx
    Session.set 'questionState', QuestionState.SHARE

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
    $audioPlayer().bind 'timeupdate', ->
      percent = (this.currentTime * 100) / this.duration
      Session.set 'gameProgress', percent
      value = (currentQuiz().pointsPerQuestion * (100 - percent)) / 100

      if percent == 0
        text = ""
      else
        text = Math.floor(value) + " point"

      # update progress bar width depending on audio progress
      $('#asset-bar')
        .attr('style', "width: #{100 - percent}%")
        .text text

Template.question.helpers
  currentQuestion: -> currentQuiz().name

  currentQuestionNumber: -> currentGame().currentQuestion + 1

  numberOfQuestions: -> numberOfQuestions()

  alternatives: -> _.shuffle currentQuestion().alternatives

  progressBarColor: ->
    percent = Session.get 'gameProgress'
    if percent is 100
      ''
    else if percent > 66
      'progress-bar-danger'
    else if percent > 33
      'progress-bar-warning'
    else
      'progress-bar-success'

  enabledAnswers: -> # TODO:
    predefined: yes
    freeText: yes

  # TODO: get actual answer, not id, remember answer types
  countdownClass: ->
    'hidden' unless Template.question.state().countdown

  lastAnswer: -> Session.get 'lastAnswer'

  state: ->
    playing: Session.get('questionState') is QuestionState.PLAY
    sharing: Session.get('questionState') is QuestionState.SHARE
    initial: Session.get('questionState') is QuestionState.INITIAL
    countdown: Session.get('questionState') is QuestionState.COUNTDOWN

Template.question.startNextQuestion = ->
  # inc current question
  Session.set 'currentQuestion', (Session.get('currentQuestion') + 1)
  Session.set 'questionState', QuestionState.PLAY

  Template.question.showQuestion()

Template.question.showQuestion = ->
  Meteor.call 'startQuestion', currentGameId(), (err) ->
    if err?
      console.log err
    else
      Session.set 'questionState', QuestionState.PLAY

      # Enable answer buttons
      $('.alternative').prop 'disabled', false

      # Play sound
      Template.assets.loadSound()
      Template.assets.playAsset()

# **iOS**: Ensure that sound is started
Template.question.ensurePlaying = ->
  Template.question.startQuestion()

# rendered
Template.question.rendered = ->
  Session.set 'questionState', QuestionState.INITIAL

# events
Template.question.events
  # answer question with predefined alternative
  'click .alternative-predefined': (event) ->
    $('.alternative').prop 'disabled', true
    Meteor.call 'stopQuestion',
      currentGameId(), event.target.id, (err, result) ->
        if err?
          console.log err
        else
          answerQuestion result

  # answer question with free text input
  'click button.start-quiz': (event) ->
    Template.assets.playSilence()

    startAnimation()

  # answer question with free text input
  'click .alternative-free-text': (event) ->
    answer = $('.free-text > input').val()
    # TODO:
    alert "Free text not yet implemented\nAnswer was '#{answer}'"

  'click .next-question': (event) ->
    startAnimation()
