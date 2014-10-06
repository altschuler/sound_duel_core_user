# app/client/stats.coffee

# methods

answerQuestion = (answer) ->
  # pause asset
  audioPlayer().pause()
  $audioPlayer().unbind('timeupdate')


# helpers

Template.data.helpers
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


#Template.stats.startQuestion = ->
  # Reset progress bar



# events
Template.data.events
  # answer question with clicked alternative
  'click .download': (event) ->
    $('.alternative').prop 'disabled', true
