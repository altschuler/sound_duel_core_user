# Client
#

# Helpers

Handlebars.registerHelper 'app_name', ->
  "Sound-Duel"

current_player = -> @Players.findOne Session.get('player_id')
Handlebars.registerHelper 'current_player', current_player

current_game = -> current_player and current_player.game_id and @Games.findOne current_player.game_id
Handlebars.registerHelper 'current_game', current_game

player_count = ->
  @Players.find({
    _id:     { $ne: Session.get('player_id') },
    name:    { $ne: '' },
    game_id: { $exists: false }
  }).count()
Handlebars.registerHelper 'player_count', player_count


# Templates

Template.players.players = ->
  @Players.find
    _id:     { $ne: Session.get('player_id') },
    name:    { $ne: '' },
    game_id: { $exists: false }

Template.lobby.disabled = ->
  if current_player and current_player.name != '' then '' else 'disabled="disabled"'

Template.lobby.events
  'keyup input#myname': (evt) ->
    name = $('input#myname').val().replace /^\s+|\s+$/g, ""
    Players.update(Session.get('player_id'), {$set: {name: name}})    
#  'click input#startgame': ->
#    Meteor.call 'start_new_game'


# Initalize

Meteor.startup ->
  # Set player id to session
  Session.set 'player_id', @Players.insert({ name: '', idle: false })

  # Keep alive else idle
  Meteor.setInterval ->
    if Meteor.status().connected
      Meteor.call('keepalive', Session.get('player_id'));
  , 20*1000
