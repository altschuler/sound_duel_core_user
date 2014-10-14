# app/client/lobby/quiz.coffee

# helpers

Template.quiz.helpers
  game_name: -> "Fuld funktionalitets quiz"

Template.quizLoggedIn.helpers
  username: ->
    if Meteor.user().profile?
      Meteor.user().profile.name
    else
      ""

#events

Template.quizLoggedIn.events
  'click .js-start-game': (event) ->
    startGame quizId: Session.get('sharedQuizId')
