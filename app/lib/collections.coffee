# app/lib/collections.coffee

# collections

@Games = new Meteor.Collection 'games'

@Challenges = new Meteor.Collection 'challenges'

@Highscores = new Meteor.Collection 'highscores'

@Questions = new Meteor.Collection 'questions'

@Sounds = new Meteor.Collection 'sounds'


# publish

if Meteor.isServer
  #TODO: do not publish all facebook data. maybe none
  Meteor.publish 'users', ->
    Meteor.users.find()

  Meteor.publish 'sounds', ->
    Sounds.find()

  Meteor.publish 'games', ->
    Games.find()

  Meteor.publish 'challenges', ->
    Challenges.find()

  Meteor.publish 'highscores', ->
    Highscores.find()

  Meteor.publish 'questions', ->
    Questions.find()


# subscribe

if Meteor.isClient
  Meteor.subscribe 'users'
  Meteor.subscribe 'games'
  Meteor.subscribe 'challenges'
  Meteor.subscribe 'highscores'
  Meteor.subscribe 'questions'
  Meteor.subscribe 'sounds'


# allow

Meteor.users.allow
  insert: (userId, doc) ->
    true

  update: (userId, doc, fields, modifier) ->
    true

  remove: (userId, doc) ->
    false
