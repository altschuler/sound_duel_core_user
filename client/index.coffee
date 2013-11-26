# Client
#

# Helpers

Handlebars.registerHelper 'app_name', ->
  "Sound-Duel"

current_player = -> @Players.findOne Session.get('player_id')
Handlebars.registerHelper 'current_player', current_player

current_game = -> current_player and current_player.game_id and @Games.findOne current_player.game_id
Handlebars.registerHelper 'current_game', current_game


# Templates

Template.home.events
  'click input#startgame': ->
    #Meteor.call 'start_new_game'
