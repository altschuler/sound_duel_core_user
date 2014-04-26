# app/client/lobby/lobby.coffee

# methods

handleUsernameError = (error) ->
  if error
    $('button#new-game').prop 'disabled', true
    if error.error is 409
      FlashMessages.sendError error.reason
    else
      FlashMessages.sendError 'Ops! Something bad happened.'
      throw error

checkChallenges = (challenges) ->
  # check for results
  for c in challenges
    continue unless c.challengerId is currentPlayerId()

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

      return

  # check for challenges
  for c in challenges
    continue unless c.challengeeId is currentPlayerId()

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

      return

newPlayer = (callback) ->
  console.log 'newPlayer'

  username = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
  currentId = if currentPlayer() then currentPlayerId() else null
  console.log "currentId: #{currentId}"

  Meteor.call 'newPlayer', currentId, username, (error, result) ->
    if error
      if error.error is 409
        FlashMessages.sendError error.reason
      else
        FlashMessages.sendError 'Ops! Something bad happened.'
        throw error
    else
      # store player id
      localStorage.setItem 'playerId', result
      # fire callback (e.g. start game)
      callback error, result if callback?

startGame = ({challengeeId, acceptChallengeId}) ->
  Meteor.call 'newGame', currentPlayerId(),
  { challengeeId, acceptChallengeId }, (error, result) ->
    Router.go 'game', _id: result.gameId, action: 'play'

onlinePlayers = ->
  Meteor.users.find(
    _id: { $ne: currentPlayerId() }
    'profile.online': true
  ).fetch()


# helpers

Template.lobby.helpers
  username: ->
    currentPlayer().username if currentPlayer()?

  challenge: ->
    challenges = Challenges.find $or: [
      { challengerId: currentPlayerId() }
    , { challengeeId: currentPlayerId() }
    ]
    if challenges.count() > 0
      checkChallenges challenges.fetch()

Template.players.helpers
  onlinePlayers: onlinePlayers

  waitingPlayers: ->
    count = onlinePlayers().length
    if count is 0
      "Ingen spillere online"
    else if count is 1
      "1 spiller online:"
    else
      "#{count} spillere der er online:"


# rendered

Template.lobby.rendered = ->
  if currentPlayer()?
    $('input#name').prop 'disabled', true
    $('button#new-game').prop 'disabled', false
  else
    $('button#new-game').prop 'disabled', true


# events

Template.lobby.events
  'keyup input#name': (event) ->
    username = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
    unless username
      $('button#new-game').prop 'disabled', true
      return

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
          $('button#new-game').prop 'disabled', false

  'click button#new-game': startGame

  'click a.player': (event) ->
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
