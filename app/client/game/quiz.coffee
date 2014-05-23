# app/client/game/play.coffee

# methods


answerQuestion = (answer) ->
  # pause asset
  currentAsset().pause()
  $(currentAsset()).unbind('timeupdate')

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

  question_counter = Session.get('currentQuestion')

  # If we answered the last question
  if question_counter + 1 == currentQuiz().questionIds.length
    Meteor.call 'endGame', currentGameId(), (error, result) ->
      Router.go 'game', _id: currentGameId(), action: 'result'
  else
    # otherwise go to the next question
    Session.set('currentQuestion', question_counter + 1)
    Template.question.startQuestion()


randomSegment = (sound) ->
  unless sound.segments?.length then return null
  sound.segments[Math.floor(Math.random() * sound.segments.length)]


# helpers

Template.assets.helpers
  segments: ->
    questions = currentQuiz().questionIds.map (id) -> Questions.findOne id
    sounds = questions.map (question) -> Sounds.findOne question.soundId

    # wrap the sound segments with id
    sounds.map (sound) ->
      id:   sound._id
      path: "/audio/#{randomSegment(sound)}"

  # start playback of audio element
  playAsset: (callback) ->
    asset = currentAsset()

    # bind audio progress
    @bindAssetProgress asset
    # play asset
    asset.play()

    ## check that the audio element is playing, if not deal with it
    # setTimeout( ->
    #   if asset.paused
    #     notify
    #       title:   "Gør dig klar!"
    #       confirm: "Spil!"
    #   else
    #     $('.alternative').prop 'disabled', false
    #     callback asset if callback?
    # , 1000)

  # binds audio element progression with progress bar
  bindAssetProgress: (asset) ->
    $(asset).bind 'timeupdate', ->
      percent = (this.currentTime * 100) / this.duration
      Session.set 'gameProgress', percent
      value = (currentGame().pointsPerQuestion * (100 - percent)) / 100

      # update progress bar width depending on audio progress
      $('#asset-bar')
        .attr('style', "width: #{100 - percent}%")
        .text Math.floor(value)

# Template.quiz.helpers
#   currentGameId: ->
#     currentGameId()

Template.question.helpers
  currentQuestion: ->
    currentQuestion = (currentGame().currentQuestion + 1)
    "#{currentQuestion}/#{numberOfQuestions()}"

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


Template.question.startQuestion = ->
  # Reset progress bar
  $('#asset-bar')
    .attr('style', "width: 100%")
    .text Math.floor(currentQuiz().pointsPerQuestion)

  $('.alternative').prop 'disabled', false
  playAsset

# rendered
Template.question.rendered = ->
  Template.question.startQuestion()


# events
Template.question.events
  # answer question with clicked alternative
  'click .alternative': (event) ->
    $('.alternative').prop 'disabled', true
    answerQuestion event.target.id
