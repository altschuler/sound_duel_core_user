# app/client/game/play.coffee

# methods

bindAssetProgress = (asset) ->
  $(asset).bind 'timeupdate', ->
    percent = (this.currentTime * 100) / this.duration
    value = (currentGame().pointsPerQuestion * (100 - percent)) / 100

    $('#asset-bar').attr 'style', "width: #{100 - percent}%"
    $('#asset-bar').text Math.floor value


# helpers

Handlebars.registerHelper 'loading', -> loadingProgress == 100

Template.assets.helpers
  segments: ->
    questions = currentGame().questionIds.map (id) -> Questions.findOne id
    sounds = questions.map (question) -> Sounds.findOne question.soundId

    hash = []
    for sound, i in sounds
      hash.push {
        id: sound._id,
        path:  "/audio/#{sound.randomSegment()}"
      }
    hash

Template.game.helpers
  currentQuestion: ->
    currentQuestion = (currentGame().currentQuestion + 1)
    "#{currentQuestion}/#{numberOfQuestions()}"

  alternatives: ->
    q = currentQuestion()
    # TODO: alternatives shouldn't be called here
    if q then q.alternatives

  alternativeDisabled: ->
    unless currentQuestion().answerable then 'disabled'

# rendered

Template.game.rendered = ->
  bindAssetProgress currentAsset()


# events

Template.play.events
  'click .alternative': (event) ->
    # pause asset
    currentAsset().pause()

    # calculate points
    points = parseInt($('#asset-bar').text(), 10)
    # if asset hasn't started, max points
    if isNaN points then points = currentGame().pointsPerQuestion

    # get clicked alternative
    answer = $(event.target).attr('id')

    # update game
    Games.update currentGame()._id,
      $addToSet:
        answers:
          questionId: currentQuestion()._id
          answer: answer
          points: points
      $inc:
        currentQuestion: 1

    # if out of questions, end of game
    if currentQuestion()
      bindAssetProgress currentAsset()

      forcePlayAudio currentAsset(), ->
        Questions.update currentQuestionId(),
          $set: { answerable: true }
    else
      Meteor.call 'endGame', Meteor.userId(), (error, result) ->
        Meteor.Router.to "/games/#{currentGameId()}/result"
