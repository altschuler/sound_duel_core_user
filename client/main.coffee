# client-side
# main

# Initialize

Meteor.startup ->
  # Keep alive else idle
  Meteor.setInterval ->
    if Meteor.status().connected
      Meteor.call 'keepalive', Session.get('player_id')
  , 20*1000
