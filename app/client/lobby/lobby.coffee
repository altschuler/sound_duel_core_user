# app/client/lobby/lobby.coffee

# methods

checkChallenges = (challenges) ->
  # check for results
  challenges.forEach (c) ->
    return true unless c.challengerId is currentPlayerId()

    challengerGame = Games.findOne c.challengerGameId
    challengeeGame = Games.findOne c.challengeeGameId

    finished = challengerGame.state is 'finished' and
      challengeeGame.state is 'finished'

    if finished and not c.notified
      Session.set 'challengeId', c._id
      Session.set 'gameId', c.challengerGameId
      challengee = Meteor.users.findOne c.challengeeId

      notify
        title:   "Dyst besvaret!"
        content: challengee.username +
          " har besvaret din udfordring. Se hvem der vandt?"
        cancel:  "Nej tak"
        confirm: "Se resultat"

      Challenges.update currentChallenge()._id, $set: { notified: true }

      return false

  challenges.rewind()

  # check for challenges
  challenges.forEach (c) ->
    return true unless c.challengeeId is currentPlayerId()

    challengerGame = Games.findOne c.challengerGameId
    challengeeGame = Games.findOne c.challengeeGameId

    if challengeeGame.state is 'init' and challengerGame.state is 'finished'
      Session.set 'challengeId', c._id
      Session.set 'gameId', c.challengeeGameId
      challenger = Meteor.users.findOne c.challengerId

      notify
        title:   "Du er blevet udfordret!"
        content: challenger.username +
          " har udfordret dig til dyst. Vil du godkende?"
        cancel:  "Nej tak"
        confirm: "Accepter dyst"

      return false

startGame = ({challengeeId, acceptChallengeId, challengeeEmail}) ->
  Meteor.call 'newGame', currentPlayerId(),
  { challengeeId, acceptChallengeId, challengeeEmail }, (error, result) ->
    Router.go 'game', _id: result.gameId, action: 'play'

onlinePlayers = ->
  playerId = Session.get('playerId') or currentPlayerId()
  Meteor.users.find(
    _id: { $ne: playerId }
    'profile.online': true
  )

handleUsernameError = (error) ->
  $('button#new-game').prop 'disabled', true
  if error.error is 409
    Session.set 'usernameError', error.reason
  else
    Session.set 'usernameError', 'Ops! Something bad happened.'
    throw error


# helpers

Template.lobby.helpers
  username: ->
    Meteor.user().profile.name

  usernameError: -> Session.get 'usernameError'

  usernameDisabled: ->
    'disabled' if currentPlayer()?

  newGameDisabled: ->
    'disabled' unless currentPlayer()?

  challenge: ->
    challenges = Challenges.find $or: [
      { challengerId: currentPlayerId() }
    , { challengeeId: currentPlayerId() }
    ]
    if challenges.count() > 0
      checkChallenges challenges

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


# rendered

Template.lobby.rendered = ->
  $('.form-inline').bind 'keydown', (e) ->
    if e.keyCode is 13
      e.preventDefault()


# events

nameInputTimeout = null

Template.lobby.events
  'keyup input#username': (event) ->
    if event.keyCode is 13
      $('#new-game').click()
      return

    username = "#{$('input#username').val()}".replace /^\s+|\s+$/g, ""
    unless username
      $('button#new-game').prop 'disabled', true
      return

    Session.set 'usernameError', ''

    clearTimeout nameInputTimeout if nameInputTimeout?

    nameInputTimeout = setTimeout(->
      if currentPlayer()
        if currentPlayer().username isnt username
          Meteor.call 'updatePlayerUsername', currentPlayerId(), username,
          (error, result) ->
            if error?
              handleUsernameError error
            else
              $('button#new-game').prop 'disabled', false
        else
          $('button#new-game').prop 'disabled', false
      else
        Meteor.call 'newPlayer', username, (error, result) ->
          if error?
            handleUsernameError error
          else
            localStorage.setItem 'playerId', result
            Session.set 'playerId', result
            $('button#new-game').prop 'disabled', false
    , 100)

  'click button[data-startGame]': startGame

  'click a.player': (event) ->
    unless currentPlayer()?
      Session.set 'usernameError', 'You must first choose a username.'
      return
    startGame { challengeeId: event.target.id }

Template.popup.events
  'click #popup-confirm': (event) ->
    text = $('#popup-confirm').text().replace /^\s+|\s+$/g, ""
    switch text
      when "Accepter dyst"
        challenge = Challenges.findOne { challengeeGameId: currentGameId() }
        setTimeout (-> startGame { acceptChallengeId: challenge._id }), 500
      when "Se resultat"
        gameId = currentChallenge().challengerGameId
        setTimeout (-> Router.go 'game', _id: gameId, action: 'result'), 500

  'click #popup-cancel': (event) ->
    text = $('#popup-cancel').text().replace /^\s+|\s+$/g, ""
    switch text
      when "Nej tak"
        Games.update currentGameId(), $set: { state: 'declined' }
