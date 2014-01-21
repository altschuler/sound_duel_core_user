# app/client/game/play.coffee


# methods

# bind progress bar to asset
bind_asset_progress = (i) ->
  $asset = $('.asset#' + i)

  $asset.bind 'timeupdate', ->
    percent = ($asset[0].currentTime * 100) / $asset[0].duration
    value = (current_game().points_per_question * (100 - percent)) / 100

    $('#asset-bar').attr 'style', "width: #{100 - percent}%"
    $('#asset-bar').text Math.floor value

# bind progress bar to loading
loading_progress = 0
bind_asset_loading = (asset) ->
  # calculate amount loaded
  buffer_end = asset.buffered.end 0
  buffer_prog = Math.round((buffer_end / asset.duration) * 100)

  # calculate new width
  current = Math.round buffer_prog / number_of_questions()
  loading_progress += current

  # set new width
  parent_width = $('#loading-bar').offsetParent().width()
  $('#loading-bar').css 'width', "#{(loading_progress / 100) * parent_width}"


# helpers

Handlebars.registerHelper 'loading', -> loading_progress == 100

Template.asset.helpers
  segments: ->
    questions = current_game().question_ids.map (id) -> Questions.findOne id
    sounds = questions.map (question) -> Sounds.findOne question.sound_id

    hash = []
    for sound, i in sounds
      hash.push {
        index: i
        path:  "/assets/#{sound.random_segment()}"
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
  count = $('.asset').length - 1
  (async_bind = ->
    unless count >= 0 then return

    $asset = $(".asset##{count}")
    $asset.bind 'loadedmetadata', ->
      bind_asset_loading this

    setTimeout async_bind, 0
    count--
  )()

  (async_load = ->
    if loading_progress >= 100
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
