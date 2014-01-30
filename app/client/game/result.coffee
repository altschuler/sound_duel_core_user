# app/client/game/result.coffee

# helpers

Template.result.helpers
  score: ->
    currentHighscore().score

  ratio: ->
    "#{currentHighscore().correct}/#{numberOfQuestions()}"


# events

Template.result.events
  'click a#restart': ->
    Session.set('guest', '')
    Session.set('gameId', '')
    Meteor.Router.to '/'
    #location.reload()
