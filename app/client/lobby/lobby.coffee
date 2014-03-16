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
    challengee = Meteor.users.findOne c.challengeeId

    if challengerGame.state is 'finished' and challengeeGame.state is 'finished'
      notify
        title:   "Dyst besvaret!"
        content: "#{challengee.username} har besvaret
        din utfordring med. Se hvem der vant?"
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
      challenger = Meteor.users.findOne c.challengerId

      notify
        title:   "Du er blevet udfordret!"
        content: challenger.username +
          " har udfordret dig til dyst. Vil du godkende?"
        cancel:  "Nei takk"
        confirm: "Aksepter dyst"

      return

newPlayer = (callback) ->
  name = "#{$('input#name').val()}".replace /^\s+|\s+$/g, ""
  unless name
    alert "Brugernavn ikke satt"
    return

  Meteor.call 'newPlayer', name, (error, result) ->
    console.log "new player (id: #{result}, error: #{error})"
    if error
      console.log error
      Meteor.Router.to '/'

      if error.error is 409
        alert "Brugernavn taget"
      else
        alert error.message

    else
      localStorage.setItem 'playerId', result
      callback error, result

newGame = ({challengeeId, acceptChallengeId}) ->
  startGame = ->
    console.log "starting game..."
    Meteor.call 'newGame', currentPlayerId(),
    {challengeeId, acceptChallengeId}, (error, result) ->

      Session.set 'gameId', result
      Meteor.Router.to "/games/#{result}/play"

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

  'click a.player': (event, template) ->
    newGame { challengeeId: $(event.target).attr('id') }

  'click button#new-game': newGame

  'click #popup-confirm': (event) ->
    # TODO: Smellz
    if $('#popup-confirm').text().match "Aksepter dyst"
      setTimeout ->
        newGame { acceptChallengeId: Session.get 'challengeId' }
      , 500
