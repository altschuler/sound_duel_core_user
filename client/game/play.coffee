# client/game/play.coffee

Template.play.current_question = ->
  current_question = (current_game().current_question + 1)
  total_questions = current_game().question_ids.length

  current_question + '/' + total_questions

Template.audio.sound_segment = ->
  random_segment()

Template.alternatives.alternatives = ->
  current_question().alternatives

once = true
Template.play.rendered = ->
  if once then once = false else return # only run once

  $('#audio').bind 'timeupdate', ->
    value = 100 - (($('#audio')[0].currentTime * 100) / $('#audio')[0].duration)
    $('.bar').attr 'style', "width: " + value + "%"
    $('.bar').text Math.floor (current_game().points_per_question * value) / 100

Template.play.events
  'click a.alternative': (event) ->
    $('#audio')[0].pause()

    points = parseInt($('.bar').text(), 10)
    answer = event.target.text[0]

    Games.update current_game()._id,
      $addToSet:
        answers: {
          question_id: current_question()._id
          answer: answer
          points: points
        }
      $inc:
        current_question: 1

    unless current_question()
      Games.update current_game()._id,
        $set:
          finished: true

      Meteor.Router.to "/games/#{current_game()._id}/result"
    else
      setTimeout ->
        $('#audio').attr 'src', random_segment()
        $('#audio')[0].load()
        $('#audio')[0].play()
      , 1000
