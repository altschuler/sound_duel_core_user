# Server side - game logic

# Settings

NUMBER_OF_QUESTION = 4
START_POINTS = 1000

# Methods
Meteor.methods
  'keepalive': (player_id) ->
    #check player_id, String
    @Players.update(
      { _id: player_id },
      { $set: {
        last_keepalive: (new Date()).getTime(),
        idle: false } })
  'start_new_game': ->
    #game_id = @Games.insert


# Update players to idle with keepalive
Meteor.setInterval ->
  now = (new Date()).getTime()
  idle_threshold = now - 70*1000 # 70 sec
  remove_threshold = now - 60*60*1000 # 1hr

  @Players.update(
    { last_keepalive: { $lt: idle_threshold } },
    { $set: { idle: true } })

  # TODO: need to deal with people coming back!
  @Players.remove { $lt: { last_keepalive: remove_threshold } }

, 30*1000
