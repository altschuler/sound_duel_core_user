# app/client/game/result.coffee

# methods

currentPlayerRole = ->
  game = currentGame()
  player = Meteor.users.findOne game.playerId

  if player._id is currentChallenge().challengerId
    'challenger'
  else
    'challengee'

currentOpponent = ->
  if currentPlayerRole() is 'challengee'
    opponent = Meteor.users.findOne currentChallenge().challengerId

  else if currentChallenge().challengeeEmail
    opponent = Meteor.users.findOne emails:
      $elemMatch: { address: currentChallenge().challengeeEmail }

    return "afventer svar" unless opponent?

  else
    opponent = Meteor.users.findOne currentChallenge().challengeeId

  opponent.profile.name

winnerRole = ->
  challenge = currentChallenge()
  challengeeGame = Games.findOne challenge.challengeeGameId

  return unless challengeeGame.state is 'finished'

  challengerGame = Games.findOne challenge.challengerGameId

  if challengeeGame.score > challengerGame.score
    'challengee'
  else if challengeeGame.score < challengerGame.score
    'challenger'
  else
    'tie'

notifyFinishedGame = ->
  challenge = currentChallenge()

  #TODO: set notification status so emails will only be sent once
  if Meteor.userId() and challenge.challengeeEmail
    if currentPlayerRole() is 'challenger'
      #send invite mail to challengee when challenger has played
      notifyUserOnChallenge challenge.challengeeEmail Meteor.userId()
    else
      #send info mail to challenger when challengee has played
      challenger = Meteor.users.findOne challenge.challengerId
      notifyUserOnAnswer challenger.emails[0].address Meteor.userId()


# helpers

Template.result.helpers
  player: ->
    player = Meteor.users.findOne currentGame().playerId
    player.profile.name

  result: ->
    game = currentGame()
    {
      score: game.score
      ratio: "#{game.correctAnswers}/#{numberOfQuestions()}"
    }

  isChallenge: -> currentChallenge()?

Template.challenge.helpers
  opponent: -> currentOpponent()

  answered: ->
    game = Games.findOne currentChallenge().challengeeGameId

    # so challenger wont be notified of a seen result
    if game.state is 'finished' and currentPlayerRole() is 'challenger'
      Challenges.update currentChallenge()._id, $set: { notified: true }

    game.state is 'finished'

  declined: ->
    Games.findOne(currentChallenge().challengeeGameId).state is 'declined'

  result: ->
    if currentPlayerRole() is 'challenger'
      game = Games.findOne currentChallenge().challengeeGameId
    else
      game = Games.findOne currentChallenge().challengerGameId
    {
      score: game.score
      ratio: "#{game.correctAnswers}/#{numberOfQuestions()}"
    }

  isWinner: ->
    winner = winnerRole()
    return unless winner

    if winner is 'tie'
      "alert alert-warning"
    else if winner is currentPlayerRole()
      "alert alert-success"
    else
      "alert alert-danger"

  winner: ->
    winner = winnerRole()
    return unless winner

    if winner is 'tie'
      "Wow, der ble uafgjort!"
    else if winner is currentPlayerRole()
      "Tillykke, du har vundet!"
    else
      "Ugh, du har tabt!"

Template.socialshare.helpers
  url: -> Meteor.absoluteUrl(Router.current().path)


# events

Template.socialshare.events
  'click .js-share-facebook': (event) ->
    event.preventDefault()
    FB.ui({
      # method: 'share_open_graph',
      # action_type: 'og.likes',
      # action_properties: JSON.stringify({
      #   object:window.location.href,
      # })
      method: 'share',
      href: Meteor.absoluteUrl(Router.current().path),
    }, (response) ->
      console.log(response)
    )
  'click .js-share-google,.js-share-twitter': (event) ->
    event.preventDefault()
    width = 400
    height = 300
    $window = $(window)
    leftPosition = ($window.width() / 2) - ((width / 2) + 10)
    topPosition = ($window.height() / 2) - ((height / 2) + 50)
    windowFeatures = "status=no,height=" +height +
    ",width=" + width +
    ",resizable=yes,left=" + leftPosition +
    ",top=" + topPosition +
    ",toolbar=no,menubar=no,scrollbars=no,location=no,directories=no"
    window.open($(event.target).attr('href'),'sharer', windowFeatures)

Template.result.events
  'click a#restart': ->
    Session.set 'currentGameId', ''
    Router.go 'lobby'


# on render

Template.result.created = ->
  game = currentGame()
  player = Meteor.users.findOne game.playerId

  unless currentChallenge()?
    description = "#{player.profile.name}" +
    " havde #{game.correctAnswers}/#{numberOfQuestions()} rigtige svar"+
    " og fik #{game.score} point!"

  else
    winner = winnerRole()

    if winner
      if winner is 'tie'
        text = ' blev uafgjort i en dyst mod '
      else if winner is currentPlayerRole()
        text = ' vandt en dyst mod '
      else
        text = ' tabte en dyst mod '

      description = player.profile.name + text + currentOpponent() + "!"

    else
      description = "#{player.profile.name} har inviteret en ven til en dyst!"

  headData {
    description: description
    og: {
      description: description
    }
  }
