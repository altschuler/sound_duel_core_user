# app/client/lobby/lobby.coffee

# methods

checkChallenges = ->
  # check for results of earlier challenges
  challenges = Challenges.find(
    challengerId: currentPlayerId()
  ).fetch()

  for c in challenges
    challengerGame = Games.findOne c.challengerGameId
    challengeeGame = Games.findOne c.challengeeGameId


    if challengerGame.state is 'finished' and challengeeGame.state is 'finished'
      Session.set 'challengeId', c._id
      Session.set 'gameId', c.challengerGameId
      challengee = Meteor.users.findOne c.challengeeId

      notify
        title:   "Dyst besvaret!"
        content: challengee.username +
          " har besvaret din utfordring. Se hvem der vant?"
        cancel:  "Nei takk"
        confirm: "Se resultat"

      return

  # check for challenges
  challenges = Challenges.find(
    challengeeId: currentPlayerId()
  ).fetch()

  for c in challenges
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
  username = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""

  Meteor.call 'newPlayer', username, (error, result) ->
    if error
      if error.error is 409
        alert error.message
      else
        throw error
    else
      localStorage.setItem 'playerId', result
      callback error, result

newGame = ({challengeeId, acceptChallengeId}) ->
  startGame = ->
    Meteor.call 'newGame', currentPlayerId(),
    {challengeeId, acceptChallengeId}, (error, result) ->

      Session.set 'gameId', result.gameId
      Session.set 'challengeId', result.challengeId
      Meteor.Router.to "/games/#{result.gameId}/play"

  if currentPlayer()
    startGame()
  else
    newPlayer startGame

onlinePlayers = ->
  Meteor.users.find
    _id: { $ne: currentPlayerId() }
    'profile.online': true
  .fetch()

# helpers

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
  if currentPlayer()
    $('input#name').val currentPlayer().username
    $('input#name').prop 'disabled', true
    $('button#new-game').prop 'disabled', false
    checkChallenges()


# events

Template.lobby.events
  'keyup input#name': (event, template) ->
    if event.keyCode is 13
      $('button#new-game').click()
    else
      name = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
      if name
        $('button#new-game').prop 'disabled', false
      else
        $('button#new-game').prop 'disabled', true

  'click button#new-game': newGame

  'click a.player': (event, template) ->
    newGame { challengeeId: $(event.target).attr('id') }

  'click #popup-confirm': (event) ->
    # TODO: Smellz
    switch $('#popup-confirm').text()
      when "Aksepter dyst"
        #gameId = currentPlayer().gameId
        challenge = Challenges.findOne { challengeeGameId: currentGameId() }
        setTimeout ->
          newGame { acceptChallengeId: challenge._id }
        , 500
      when "Se resultat"
        gameId = currentChallenge().challengerGameId
        Meteor.Router.to "/games/#{gameId}/result"
