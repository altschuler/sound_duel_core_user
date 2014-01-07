# client/result/result.coffee

Template.result.result = ->
  points = 0
  correct = 0
  total = current_game().question_ids.length

  for a in current_game().answers
    if a.answer is Questions.findOne(a.question_id).correct_answer
      correct++
      points += a.points

  { "points": points, "correct": correct + '/' + total }

Template.result.events
  'click a#restart': ->
    Session.set('player_id', '')
    location.reload()
