# app/client/lib/collections/users.coffee

# permission

Meteor.users.allow
  insert: (userId, doc) -> false

  update: (userId, doc, fields, modifier) -> false

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'currentUser', ->
    Meteor.users.find _id: this.userId

  Meteor.publish 'users', ->
    Meteor.users.find {},
      fields:
        profile: 1
        username: 1
        emails: 1

  # Meteor.publish 'challengee', (challengeId) ->
  #   Challenges.findOne
