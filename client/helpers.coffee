# client/helpers.coffee

@current_game = ->
  Games.findOne(Session.get 'game_id')

@current_question = ->
  unless current_game().current_question >= current_game().question_ids.length
    question_id = current_game().question_ids[current_game().current_question]
    Questions.findOne question_id

#@random_segment = ->
#  sound = Sounds.findOne current_question().sound_id
#  "/audio/" + sound.random_segment()

@current_player = ->
  # lazy init player
  id = Session.get 'player_id'
  unless id or Players.findOne id
    # set player id to session
    id = Players.insert { name: '', idle: false }
    Session.set 'player_id', id
  else

  Players.findOne id

@online_players = ->
  @Players.find
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
