# app/client/game/result.coffee

# helpers

Template.result.result = ->
  points = 0
  correct = 0

  for a in current_game().answers
    q = Questions.findOne(a.question_id)
    if a.answer is q.correct_answer
      correct++
      points += a.points

  {
    "points": points,
    "correct": correct + '/' + number_of_questions()
  }


# events

Template.result.events
  'click a#restart': ->
    Session.set('player_id', '')
    Session.set('game_id', '')
    # Reset the game_id on the player.
    Meteor.Router.to '/'
