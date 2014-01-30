# app/client/game/result.coffee

# helpers

Template.result.result = ->
  points = 0
  correct = 0

  for a in currentGame().answers
    q = Questions.findOne(a.questionId)
    if a.answer is q.correctAnswer
      correct++
      points += a.points

  {
    "points": points,
    "correct": correct + '/' + numberOfQuestions()
  }


# events

Template.result.events
  'click a#restart': ->
    Session.set('guest', '')
    Session.set('gameId', '')
    Meteor.Router.to '/'
    #location.reload()
