# app/lib/collections.coffee

# collections

@Sounds = new Meteor.Collection 'sounds'

@Games = new Meteor.Collection 'games'

@Challenges = new Meteor.Collection 'challenges'

@Highscores = new Meteor.Collection 'highscores'

@Questions = new Meteor.Collection 'questions'


# allow

Meteor.users.allow
  insert: (userId, doc) ->
    true

  update: (userId, doc, fields, modifier) ->
    true

  remove: (userId, doc) ->
    false
