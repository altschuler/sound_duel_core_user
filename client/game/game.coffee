# Game

# Templates

current_question = ->
  unless current_game().current_question >= current_game().question_ids.length
    question = current_game().question_ids[current_game().current_question]
    @Questions.findOne question

Template.game.current_question = ->
  current_question = (current_game().current_question + 1)
  total_questions = current_game().question_ids.length

  current_question + '/' + total_questions

random_segment = ->
  sound = @Sounds.findOne current_question().sound_id
  ran = Math.floor(Math.random() * sound.segments.length)
  "audio/" + sound.segments[ran]
Template.audio.sound_segment = random_segment

Template.alternatives.alternatives = ->
  current_question().alternatives

once = true
Template.game.rendered = ->
  # only run once
  if once then once = false else return

  $('#audio').bind 'timeupdate', ->
    value = 100 - (($('#audio')[0].currentTime * 100) / $('#audio')[0].duration)
    $('.bar').attr 'style', "width: " + value + "%"
    $('.bar').text Math.floor (current_game().points_per_question * value) / 100

Template.game.events
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
    else
      setTimeout( ->
        $('#audio').attr 'src', random_segment()
        $('#audio')[0].load()
        $('#audio')[0].play()
      , 1000)
