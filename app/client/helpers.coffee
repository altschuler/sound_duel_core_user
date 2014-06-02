# app/client/helpers.coffee#

# methods

# helper method for failing gracefully when required value is null
failIfNull = (value=null, msg) ->
  # if given value is null, route to home screen and throw error
  unless value?
    Router.go 'lobby'
    throw new Error msg
  # else, return the value
  else
    value


# helpers
@startGame = ({challengeeId, acceptChallengeId, challengeeEmail}) ->

  # Create the game, and go to the quiz view
  Meteor.call(
    'newGame',
    currentPlayerId(),
    { challengeeId, acceptChallengeId, challengeeEmail },
    (error, result) ->
      unless error
        Session.set 'currentQuestion', 0
        Session.set 'gameId', result.gameId
        Router.go 'quiz', _id: Games.findOne(result.gameId).quizId
      else
        console.log 'Could not create new game: %s', error.error
        console.log error
  )

@currentPlayerEmails = ->
  if Meteor.user().emails
    Meteor.user().emails.map (c) -> c.address
  else
    []

@currentPlayerId = ->
  # Session.get 'playerId' or localStorage.getItem 'playerId'
  #localStorage.getItem 'playerId'
  Meteor.userId()

@currentPlayer = ->
  #Meteor.users.findOne currentPlayerId()
  Meteor.user()

@currentGameId = ->
  Session.get 'gameId'
  #failIfNull Session.get('gameId'), 'Session gameId not set'

@currentGame = ->
  Games.findOne(currentGameId())
  # failIfNull Games.findOne(currentGameId()),
  #   "Current game not found (id: #{currentGameId()})"

@currentQuizId = ->
  Session.get 'currentQuizId'
  #failIfNull Session.get('gameId'), 'Session gameId not set'

@currentQuiz = ->
  Quizzes.findOne(currentQuizId())
  # failIfNull Quizs.findOne(currentQuizId()),
  #   "Current game not found (id: #{currentQuizId()})"

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion >= numberOfQuestions()
  outOfQuestions or currentGame().state is 'finished'

@currentChallenge = ->
  Challenges.findOne $or: [
    { challengerGameId: currentGameId() }
  , { challengeeGameId: currentGameId() }
  ]

@currentChallengeId = ->
  currentChallenge()._id

@currentHighscore = ->
  failIfNull Highscores.findOne({ gameId: currentGameId() }),
    'Current game has no highscore'

@currentQuestionId = ->
  idx = Session.get('currentQuestion')
  currentQuiz().questionIds[idx]

@currentQuestion = ->
  failIfNull Questions.findOne(currentQuestionId()),
    "Current question not found (id: #{currentQuestionId()})"

@numberOfQuestions = ->
  Quizzes.findOne(currentGame().quizId).questionIds.length

@currentAsset = ->
  $(".asset##{currentQuestion().soundId}")[0]


###{
  title: title
  description: description
  og: {
    title: title
    ..
  }
}###
@headData = (data) ->
  $head = $('head')
  if data.title
    $head.find('title').text(data.title)
  if data.description
    $head.find('description').text(data.description)
  if(data.og)
    for k in Object.keys(data.og)
      $elem = $("meta[property='og:"+k+"']")
      if $elem.length is 0
        $("<meta>", { property: 'og:'+k, content: data.og[k] }).appendTo 'head'
      else
        $elem.attr('content',data.og[k])
