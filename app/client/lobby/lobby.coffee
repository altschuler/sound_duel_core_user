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
          " har besvaret din utfordring. Se hvem der vant?"
        cancel:  "Nei takk"
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
        cancel:  "Nei takk"
        confirm: "Aksepter dyst"

      return false

startGame = ({challengeeId, acceptChallengeId}) ->
  Meteor.call 'newGame', currentPlayerId(),
  { challengeeId, acceptChallengeId }, (error, result) ->
    Router.go 'game', _id: result.gameId, action: 'play'

onlinePlayers = ->
  playerId = Session.get('playerId') or currentPlayerId()
  Meteor.users.find(
    _id: { $ne: playerId }
    'profile.online': true
  )

handleUsernameError = (error) ->
  if error
    $('button#new-game').prop 'disabled', true
    if error.error is 409
      FlashMessages.sendError error.reason
    else
      FlashMessages.sendError 'Ops! Something bad happened.'
      throw error


# helpers

Template.lobby.helpers
  username: ->
    currentPlayer().username if currentPlayer()?

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


# events

nameInputTimeout = null

Template.lobby.events
  'keyup input#username': (event) ->
    username = "#{$('input#username').val()}".replace /^\s+|\s+$/g, ""
    unless username
      $('button#new-game').prop 'disabled', true
      return

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
          if error
            handleUsernameError error
          else
            localStorage.setItem 'playerId', result
            Session.set 'playerId', result
            $('button#new-game').prop 'disabled', false
    , 100)

  'click button#new-game': startGame

  'click a.player': (event) ->
    unless currentPlayer()?
      FlashMessages.sendError 'You must first choose a username.'
      return
    startGame { challengeeId: event.target.id }

Template.popup.events
  'click #popup-confirm': (event) ->
    text = $('#popup-confirm').text().replace /^\s+|\s+$/g, ""
    switch text
      when "Aksepter dyst"
        challenge = Challenges.findOne { challengeeGameId: currentGameId() }
        setTimeout (-> startGame { acceptChallengeId: challenge._id }), 500
      when "Se resultat"
        gameId = currentChallenge().challengerGameId
        setTimeout (-> Router.go 'game', _id: gameId, action: 'result'), 500

  'click #popup-cancel': (event) ->
    text = $('#popup-cancel').text().replace /^\s+|\s+$/g, ""
    switch text
      when "Nei takk"
        Games.update currentGameId(), $set: { state: 'declined' }
