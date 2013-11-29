# Collections

@Players   = new Meteor.Collection 'players'
@Games     = new Meteor.Collection 'games'
@Questions = new Meteor.Collection 'questions'
@Sounds    = new Meteor.Collection 'sounds'

Meteor.startup ->
  # TODO: Only for development
  console.log "Clearing db.."
  @Players.remove({})
  @Games.remove({})
  @Questions.remove({})
  @Sounds.remove({})
