# Initialize

Meteor.startup ->
  # Set player id to session
  Session.set 'player_id', @Players.insert({ name: '', idle: false })

  # Keep alive else idle
  Meteor.setInterval ->
    if Meteor.status().connected
      Meteor.call('keepalive', Session.get('player_id'));
  , 20*1000
