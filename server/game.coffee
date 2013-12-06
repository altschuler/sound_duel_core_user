# Server side - game logic

# Settings
NUMBER_OF_QUESTION = 5
TIME_PER_QUESTION  = 30
START_POINTS       = 1000

# Methods
Meteor.methods
  keepalive: (player_id) ->
    #check player_id, String
    @Players.update(
      { _id: player_id }
      { $set: {
          last_keepalive: (new Date()).getTime(),
          idle: false
        }
      }
    )

  start_new_game: ->


    player_id = Session.get 'player_id'

    Players.update({ _id: player_id },
      { $set: { game_id: game_id } }
    )

