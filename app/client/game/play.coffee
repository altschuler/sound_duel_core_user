# app/client/game/play.coffee


# methods

bind_asset_progress = (i) ->
  $asset = $('.asset#' + i)

  $asset.bind 'timeupdate', ->
    percent = ($asset[0].currentTime * 100) / $asset[0].duration
    value = (current_game().points_per_question * (100 - percent)) / 100

    $('#asset-bar').attr 'style', "width: #{100 - percent}%"
    $('#asset-bar').text Math.floor value

update_loadingbar = ->
  $assets = $('.asset')
  progress = 0.0

  for audio in $assets
    if audio.duration
      score = (audio.buffered.end(0) / audio.duration) * 90 #100
    else
      score = 0

    progress += Math.round (score + 10) / $assets.length

  $('#loading-bar').text progress
  parent_width = $('#loading-bar').parent().width()
  $('#loading-bar').css 'width', "#{(progress / 100) * parent_width}"


# helpers

Handlebars.registerHelper 'loading', -> loading_progress == 100

Template.assets.helpers
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
  (async_update = ->
    if $('#loading-bar').text() is '100'
      $('button#play').removeAttr 'disabled'
      console.log "STAP"
    else
      update_loadingbar()
      setTimeout async_update, 10
  )()


# events

Template.play.events
  'click button#play': (event) ->
    # render game view
    html = Meteor.render ->
      Template['game']()
    $('div.container').html html

    bind_asset_progress current_game().current_question

    setTimeout( ->
      $('.asset:first')[0].play()
    , 500)

  'click a.alternative': (event) ->
    # pause asset
    $('.asset')[current_game().current_question].pause()

    # calculate points
    points = parseInt($('#asset-bar').text(), 10)
    # if asset hasn't started, max points
    if isNaN points then points = CONFIG.POINTS_PER_QUESTION

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
      bind_asset_progress current_game().current_question

      setTimeout( ->
        $('.asset#' + current_game().current_question)[0].play()
      , 500)
    else
      Games.update current_game()._id, {$set: {finished: true}}

      Meteor.Router.to "/games/#{current_game()._id}/result"
