# app/client/helpers.coffee

@go_home = ->
  Meteor.Router.to '/'
  location.reload()

@force_play_audio = (audio_selector, callback) ->
  play_interval = setInterval ->
    $assets = $(audio_selector)
    # Wait for the first audio asset.
    if $assets.length > 0
      assetElement = $assets.get(0)
      if not assetElement.paused
        clearInterval play_interval
        callback(assetElement)
      else
        assetElement.play()
  , 500 # TODO: Make 250, less of a magic number.

@current_game_id = ->
  id = Session.get 'game_id'
  unless id then go_home() else id

@current_game = ->
  game = Games.findOne current_game_id()
  unless game then go_home() else game

@current_question_id = ->
  current_game().question_ids[current_game().current_question]

@current_question = ->
  Questions.findOne current_question_id()

@current_asset = ->
  id = current_question().sound_id
  $('.asset#' + id).get(0)

@number_of_questions = ->
  current_game().question_ids.length

@current_guest = ->
  Session.get 'guest'

@online_players = ->
  Meteor.users.find
    _id:    { $ne: Meteor.userId() }
    online: { $ne: false }
  .fetch()
Handlebars.registerHelper 'online_players', online_players
