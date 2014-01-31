# app/client/game/result.coffee

# helpers

Template.result.helpers
  score: ->
    currentHighscore().score

  ratio: ->
    "#{currentHighscore().correctAnswers}/#{numberOfQuestions()}"


# events

Template.result.events
  'click a#restart': ->
    Session.set('gameId', '')
    Meteor.Router.to '/'
    #location.reload()
