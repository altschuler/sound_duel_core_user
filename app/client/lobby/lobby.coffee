# app/client/lobby/lobby.coffee

# methods

checkChallenges = ->
  challengeId = currentPlayer().profile.challenges.pop()
  if challengeId
    Session.set 'challengeId', challengeId

    challenge = Challenges.findOne challengeId
    challenger = Meteor.users.findOne challenge.challengerId

    notify
      title:   "Du er blevet udfordret!"
      content: challenger.username +
        " har udfordret dig til dyst. Vil du godkende?"
      cancel:  "Gå tilbake"
      confirm: "Starte spill!"

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


newGame = ({challengeeId, answerChallengeId}) ->
  startGame = ->
    console.log "starting game..."
    Meteor.call 'newGame', currentPlayerId(),
    {challengeeId, answerChallengeId}, (error, result) ->

      Session.set 'gameId', result
      Meteor.Router.to "/games/#{currentGameId()}/play"

  if currentPlayer()
    startGame()
  else
    newPlayer startGame


# helpers

Template.players.helpers
  waiting: ->
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
    setTimeout ->
      newGame { acceptChallengeId: Session.get 'challengeId' }
    , 500
