# app/client/lobby/lobby.coffee

# methods

startChallenge = -> notify
  title:   "Udfordr ven!"
  content: '<input type="text">'
  cancel:  "Annuller"
  confirm: "Inviter"


onlinePlayers = ->
  playerId = Session.get('playerId') or currentPlayerId()
  Meteor.users.find(
    _id: { $ne: playerId }
    'online': true
  )

handleUsernameError = (error) ->
  $('button#new-game').prop 'disabled', true
  if error.error is 409
    Session.set 'usernameError', error.reason
  else
    Session.set 'usernameError', 'Ops! Something bad happened.'
    throw error

challenges = ->
  Challenges.find $or: [
    { challengerId: currentPlayerId() }
  , { challengeeId: currentPlayerId() }
  , { challengeeEmail: { $in: currentPlayerEmails() } }
  ]


# helpers

Template.lobby.helpers
  username: ->
    if Meteor.user().profile
      Meteor.user().profile.name
    else
      Meteor.user().emails[0].address

  usernameError: -> Session.get 'usernameError'

  usernameDisabled: ->
    'disabled' if currentPlayer()?

  newGameDisabled: ->
    'disabled' unless currentPlayer()?

Template.challenges.helpers

  challengesCount: ->
    challenges().count()
    #does meteor deal with caching?
    #challengeInvites.length + challengeResults.length

  challengeInvites: ->
    retval = []
    test = challenges()
    test.fetch().forEach (c) ->
      if c.challengeeId is currentPlayerId() or
      c.challengeeEmail in currentPlayerEmails()
        challengerGame = Games.findOne c.challengerGameId
        challengeeGame = Games.findOne c.challengeeGameId
        if challengeeGame.state is 'init' and
        challengerGame.state is 'finished'
          challenger = Meteor.users.findOne c.challengerId
          retval.push({
            username: challenger.profile.name
            gameId: c.challengeeGameId
          })
    retval

  challengeResults: ->
    retval = []
    test = challenges()
    test.fetch().forEach (c) ->
      if c.challengerId is currentPlayerId()
        challengerGame = Games.findOne c.challengerGameId
        challengeeGame = Games.findOne c.challengeeGameId
        if challengeeGame.state is 'finished' and
        challengerGame.state is 'finished'
          #challengee = Meteor.users.findOne c.challengeeId
          challengee = Meteor.users.findOne $or: [
            { _id: c.challengeeId }
          , { emails: { $elemMatch: { address: c.challengeeEmail } } }
          ]
          Challenges.update c._id, $set: { notified: true }
          retval.push({
            username: challengee.profile.name
            gameId: c.challengeeGameId
          })
    retval

Template.players.helpers
  onlinePlayers: onlinePlayers

  waitingPlayers: ->
    count = onlinePlayers().count()
    if count is 0
      "Ingen spillere online"
    else if count is 1
      "1 spiller online:"
    else
      "#{count} spillere der er online:"


# events

Template.challenges.events
  'click .js-invite-accept': (event) ->
    challenge = Challenges.findOne {
      #data() does not work
      challengeeGameId: $(event.target).attr('data-gameId')
    }
    startGame { acceptChallengeId: challenge._id }

  'click .js-invite-decline': (event) ->
    Games.update $(event.target).attr('data-gameId'), $set: {
      state: 'declined'
    }
