# methods

# bind progress bar to audio
bind_audio_progress = (i) ->
  $audio = $('audio#' + i)

  $audio.bind 'timeupdate', ->
    percent = ($audio[0].currentTime * 100) / $audio[0].duration
    value = (current_game().points_per_question * (100 - percent)) / 100

    $('.audio-bar').attr 'style', "width: #{100 - percent}%"
    $('.audio-bar').text Math.floor value

# bind progress bar to loading
loading_progress = 0
bind_audio_loading = (audio) ->
  # calculate amount loaded
  buffer_end = audio.buffered.end 0
  buffer_prog = Math.round((buffer_end / audio.duration) * 100)

  # calculate new width
  current = Math.round buffer_prog / number_of_questions()
  loading_progress += current

  # set new width
  parent_width = $('#loading-bar').offsetParent().width()
  $('#loading-bar').css 'width', "#{(loading_progress / 100) * parent_width}"

# helpers

Handlebars.registerHelper 'loading', -> loading_progress == 100

Template.audio.helpers
  segments: ->
    questions = current_game().question_ids.map (id) -> Questions.findOne id
    sounds = questions.map (question) -> Sounds.findOne question.sound_id

    hash = []
    for sound, i in sounds
      hash.push {
        index: i
        path:  "/audio/#{sound.random_segment()}"
      }
    hash

Template.game.helpers
  current_question: ->
    current_question = (current_game().current_question + 1)
    "#{current_question}/#{number_of_questions()}"

  alternatives: ->
    q = current_question()
    # TODO: alternatives shouldn't be called here
    if q then q.alternatives


# rendered

Template.load.rendered = ->
  # loading progress
  loading_progress = 0
  count = $('audio').length - 1
  (async_bind = ->
    unless count >= 0 then return

    $audio = $("audio##{count}")
    $audio.bind 'loadedmetadata', ->
      bind_audio_loading this

    setTimeout async_bind, 0
    count--)()

  (async_load = ->
    if loading_progress == 100
      $('button#play').removeAttr 'disabled'
    else
      setTimeout async_load, 10
  )()


# events

Template.play.events
  'click button#play': (event) ->
    # render game view
    html = Meteor.render ->
      Template['game']()
    $('div.container').html html

    bind_audio_progress current_game().current_question

    setTimeout( ->
      $('audio:first')[0].play()
    , 500)

  'click a.alternative': (event) ->
    # pause audio
    $('audio')[current_game().current_question].pause()

    # calculate points
    points = parseInt($('.audio-bar').text(), 10)
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
      bind_audio_progress current_game().current_question

      setTimeout( ->
        $('audio#' + current_game().current_question)[0].play()
      , 500)
    else
      Games.update current_game()._id, {$set: {finished: true}}

      Meteor.Router.to "/games/#{current_game()._id}/result"
