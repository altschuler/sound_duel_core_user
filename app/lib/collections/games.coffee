# app/client/lib/collections/games.coffee

@Games = new Meteor.Collection 'games'

# permission

Games.allow
  insert: (userId, doc) -> true

  update: (userId, doc, fields, modifier) ->
    allowedFields = [ 'answers', 'currentQuestion', 'state' ]
    isAllowedFields = true
    for f in fields
      unless f in allowedFields
        isAllowedFields = false

    isGameOwner = userId == doc.playerId

    unless isGameOwner
      challenge = Challenges.findOne challengeeGameId: doc._id
      user = Meteor.users.findOne userId
      if challenge?
        adresses = user.emails.map (c) -> c.address
        isChallengee = challenge.challengeeEmail in adresses
      else
        isChallengee = false

    res = isAllowedFields && (isGameOwner || isChallengee)
    console.log "Game update:"
    if res
      console.log "allowed"
    else
      console.log "DENIED"
    res

  remove: (userId, doc) -> false

# publish

if Meteor.isServer
  Meteor.publish 'games', ->
    Games.find() # TODO
