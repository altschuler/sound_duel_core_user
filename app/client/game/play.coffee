# app/client/game/play.coffee


# methods

bind_asset_progress = (i) ->
  $asset = $('.asset#' + i)

  $asset.bind 'timeupdate', ->
    percent = ($asset[0].currentTime * 100) / $asset[0].duration
    value = (current_game().points_per_question * (100 - percent)) / 100

    $('#asset-bar').attr 'style', "width: #{100 - percent}%"
    $('#asset-bar').text Math.floor value

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

  alternativesDisabled: ->
    q = current_question()
    if not q or not q.answerable
      'disabled'
    else
      ''
      


# rendered

Template.game.rendered = ->
  bind_asset_progress current_game().current_question


# events

Template.play.events
  'click .alternative': (event) ->
    # pause asset
    $('.asset')[current_game().current_question].pause()

    # calculate points
    points = parseInt($('#asset-bar').text(), 10)
    # if asset hasn't started, max points
    if isNaN points then points = CONFIG.POINTS_PER_QUESTION

    answer = $(event.target).text()[0]

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
      force_play_audio '.asset#' + current_game().current_question, ->
        Questions.update current_question()._id, {
          $set: { 'answerable': true }
        }
    else
      Games.update current_game()._id, {$set: {finished: true}}

      Meteor.Router.to "/games/#{current_game()._id}/result"
