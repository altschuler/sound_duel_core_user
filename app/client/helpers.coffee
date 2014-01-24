# app/client/helpers.coffee

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
  , 50 # TODO: Make 50, less of a magic number.

@current_game = ->
  game = Games.findOne(Session.get 'game_id')
  unless game
    Meteor.Router.to '/'
    location.reload()
  else
    game

@current_question = ->
  Questions.findOne current_game().question_ids[current_game().current_question]

@number_of_questions = ->
  current_game().question_ids.length

@current_player = ->
  # lazy init player
  id = Session.get 'player_id'
  unless id and Players.findOne id
    # create player and set id to session
    id = Players.insert { name: '', idle: false }
    Session.set 'player_id', id

  Players.findOne id

@online_players = ->
  Players.find
    _id:     { $ne: Session.get('player_id') },
    name:    { $ne: '' },
    game_id: { $exists: false }
  .fetch()

@player_count = ->
  online_players().length


Handlebars.registerHelper 'current_player', current_player

Handlebars.registerHelper 'current_game', current_game

Handlebars.registerHelper 'game_finished', ->
  current_game().finished

Handlebars.registerHelper 'online_players', online_players

Handlebars.registerHelper 'player_count', player_count
