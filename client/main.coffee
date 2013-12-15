# Initialize

Meteor.startup ->
  # Set player id to session
  player_id = @Players.insert { name: '', idle: false }
  Session.set 'player_id', player_id

  # Keep alive else idle
  Meteor.setInterval ->
    if Meteor.status().connected
      Meteor.call 'keepalive', Session.get('player_id')
  , 20*1000
