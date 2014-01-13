# client/game/result.coffee

Template.result.result = ->
  points = 0
  correct = 0
  game = Games.findOne(Session.get 'game_id')
  total = game.question_ids.length
  for a in game.answers
    if a.answer is Questions.findOne(a.question_id).correct_answer
      correct++
      points += a.points

  { "points": points, "correct": correct + '/' + total }

Template.result.events
  'click a#restart': ->
    Session.set('player_id', '')
    Meteor.Router.to '/'
