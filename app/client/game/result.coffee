# app/client/game/result.coffee

# methods

currentPlayerRole = ->
  if currentPlayerId() is currentChallenge().challengerId
    'challenger'
  else
    'challengee'

winnerRole = ->
  challenge = currentChallenge()
  return unless Games.findOne(challenge.challengeeGameId).state is 'finished'

  challengeeHighscore = Highscores.findOne
    gameId: challenge.challengeeGameId
  challengerHighscore = Highscores.findOne
    gameId: challenge.challengerGameId

  if challengeeHighscore.score > challengerHighscore.score
    'challengee'
  else if challengeeHighscore.score < challengerHighscore.score
    'challenger'
  else
    'tie'

notifyFinishedGame = ->
  challenge = currentChallenge()
  if challenge.challengeeEmail
    if currentPlayerRole() is 'challenger'
      #send invite mail to challengee when challenger has played
      Meteor.call 'sendEmail',
      challenge.challengeeEmail,
      'Invitation til spil',
      'content'
    else
      #send info mail to challenger when challengee has played
      challenger = (Meteor.users.findOne challenge.challengerId)
      Meteor.call 'sendEmail',
      challenger.profile.name + '<'+challenger.emails[0].address+'>',
      'Dyst overstået',
      'content'


# helpers

Template.result.helpers
  player: ->
    game = currentGame()
    player = Meteor.users.findOne game.playerId
    player.profile.name
  result: ->
    game = currentGame()
    {
      score: game.score
      ratio: "#{game.correctAnswers}/#{numberOfQuestions()}"
    }

  isChallenge: -> currentChallenge()?

Template.challenge.helpers
  opponent: ->
    if currentPlayerRole() is 'challengee'
      opponent = Meteor.users.findOne currentChallenge().challengerId
    else if currentChallenge().challengeeEmail
      opponent = Meteor.users.findOne {
        emails: { $elemMatch: {
          address: currentChallenge().challengeeEmail
        } }
      }
    else
      opponent = Meteor.users.findOne currentChallenge().challengeeId
    opponent.profile.name

  answered: ->
    game = Games.findOne currentChallenge().challengeeGameId

    # so challenger wont be notified of a seen result
    if game.state is 'finished' and currentPlayerRole() is 'challenger'
      Challenges.update currentChallenge()._id, $set: { notified: true }

    game.state is 'finished'

  declined: ->
    Games.findOne(currentChallenge().challengeeGameId).state is 'declined'

  result: ->
    {
      score: currentGame().score
      ratio: "#{currentGame().correctAnswers}/#{numberOfQuestions()}"
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
    Session.set 'gameId', ''
    Router.go 'lobby'


# on render

Template.result.rendered = ->
  game = currentGame()
  player = Meteor.users.findOne game.playerId
  description = player.profile.name +
  " havde #{game.correctAnswers}/#{numberOfQuestions()} rigtige svar"+
  " og fik " + game.score + " point!"
  headData {
    description: description
    og: {
      description: description
    }
  }

Template.challenge.rendered = ->
  notifyFinishedGame()
