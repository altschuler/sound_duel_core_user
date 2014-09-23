# app/client/utils/layout.coffee

# helpers
UI.registerHelper 'active', (route) ->
  currentRoute = Router.current()
  return '' unless currentRoute

  if currentRoute.route.name == route
    'active'
  else
    ''

currentPlayerEmails2 = ->
  if Meteor.user() and Meteor.user().emails
    Meteor.user().emails.map (c) -> c.address
  else
    []

notifications = ->

  notifics = []
  challenges = Challenges.find $or: [
    { challengerId: currentPlayerId() }
  , { challengeeId: currentPlayerId() }
  , { challengeeEmail: { $in: currentPlayerEmails() } }
  ]

  challenges.fetch().forEach (c) ->

    challengerGame = Games.findOne c.challengerGameId
    challengeeGame = Games.findOne c.challengeeGameId

    #duel invites
    if c.challengeeId is currentPlayerId() or
    c.challengeeEmail in currentPlayerEmails()

      if challengeeGame.state is 'init' and
      challengerGame.state is 'finished'

        challenger = Meteor.users.findOne c.challengerId

        notifics.push({
          invite: 1
          name: challenger.profile.name
          gameId: c.challengeeGameId
        })

    #duel results
    else if c.challengerId is currentPlayerId() and not c.notified

      if challengeeGame.state is 'finished' and
      challengerGame.state is 'finished'

        challengee = Meteor.users.findOne $or: [
          { _id: c.challengeeId }
        , { emails: { $elemMatch: { address: c.challengeeEmail } } }
        ]

        notifics.push({
          invite: 0
          name: challengee.profile.name
          gameId: c.challengerGameId
        })

  console.log notifics
  notifics

Template.navbar.helpers

  externallink: -> 'http://www.dr.dk/sporten/fifavm2014'

Template.currentUser.helpers

  name: ->
    Meteor.user().profile.name

Template.notifications.helpers

  count: -> notifications().length

  notifications: -> notifications()


# events

Template.notifications.events

  'click .js-invite-accept': (event) ->
    #data() does not work
    gameId = $(event.target).attr('data-gameId')
    challenge = Challenges.findOne { challengeeGameId: gameId }
    startGame { acceptChallengeId: challenge._id }

  'click .js-invite-decline': (event) ->
    gameId = $(event.target).attr('data-gameId')
    Games.update gameId, $set: { state: 'declined' }
