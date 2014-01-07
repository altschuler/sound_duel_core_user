# client/index.coffee

# helpers

@current_player = ->
  unless Session.get 'player_id'
    # Set player id to session
    player_id = @Players.insert { name: '', idle: false }
    Session.set 'player_id', player_id

  @Players.findOne Session.get 'player_id'
Handlebars.registerHelper 'current_player', current_player

@current_game = ->
  player = current_player()
  if player and player.game_id
    @Games.findOne player.game_id
Handlebars.registerHelper 'current_game', current_game

Handlebars.registerHelper 'game_finished', ->
  current_game().finished

@players = ->
  @Players.find({
    _id:     { $ne: Session.get('player_id') },
    name:    { $ne: '' },
    game_id: { $exists: false }
  }).fetch()
Handlebars.registerHelper 'players', players

@player_count = ->
  players().length
Handlebars.registerHelper 'player_count', player_count
