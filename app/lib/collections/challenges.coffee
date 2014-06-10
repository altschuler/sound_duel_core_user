# app/client/lib/collections/challenges.coffee

@Challenges = new Meteor.Collection 'challenges'

# permission

Challenges.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) ->
    allowedFields = [ 'notified' ]

    isChallenger = (userId == doc.challengerId)
    isAllowedFields = JSON.stringify(fields) == JSON.stringify(allowedFields)

    isChallenger and isAllowedFields

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'challenges', ->
    Challenges.find() # TODO
