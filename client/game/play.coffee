# client/game/play.coffee

# helpers

Template.play.current_question = ->
  current_question = (current_game().current_question + 1)
  total_questions = current_game().question_ids.length

  current_question + '/' + total_questions

Template.audio.segments = ->
  questions = current_game().question_ids.map (id) -> Questions.findOne id
  sounds = questions.map (question) -> Sounds.findOne question.sound_id

  hash = []
  for sound, i in sounds
    hash.push {
      index: i
      path:  "/audio/#{sound.random_segment()}"
    }
  hash

Template.alternatives.alternatives = ->
  current_question().alternatives


# methods

# bind progress bar to audio
prepare_audio = (i) ->
  $audio = $('audio#' + i)

  $audio.bind 'timeupdate', ->
    percent = ($audio[0].currentTime * 100) / $audio[0].duration
    value = (current_game().points_per_question * (100 - percent)) / 100

    $('.bar').attr 'style', "width: " + (100 - percent) + "%"
    $('.bar').text Math.floor value


# rendered

Template.play.rendered = ->
  prepare_audio current_game().current_question


# events

Template.play.events
  'click a.alternative': (event) ->
    # pause audio
    $('audio')[current_game().current_question].pause()

    # calculate points
    points = parseInt($('.bar').text(), 10)
    answer = event.target.text[0]

    # update game
    Games.update current_game()._id,
      $addToSet:
        answers:
          question_id: current_question()._id
          answer: answer
          points: points
      $inc:
        current_question: 1

    # if out of questions, end of game
    if current_question()
      prepare_audio current_game().current_question

      setTimeout ->
        $('audio#' + current_game().current_question)[0].play()
      , 1000
    else
      Games.update current_game()._id, {$set: {finished: true}}

      Meteor.Router.to "/games/#{current_game()._id}/result"
