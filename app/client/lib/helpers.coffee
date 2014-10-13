# app/client/helpers.coffee

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

@validateEmail = (email) ->
  pattern = /// ^
    (([^<>()[\]\\.,;:\s@\"]+
    (\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))
    @((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}
    \.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+
    [a-zA-Z]{2,}))$ ///

  email.match pattern

@startGame = ({challengeeId, acceptChallengeId, challengeeEmail}) ->
  # Create the game, and go to the quiz view
  Meteor.call 'newGame',
    currentPlayerId(),
    { challengeeId, acceptChallengeId, challengeeEmail },
    (error, result) ->
      unless error?
        Session.set 'currentQuestion', 0
        Session.set 'currentGameId', result.gameId
        Router.go 'game', action: 'play', _id: result.gameId
      else
        console.log 'Could not create new game: %s', error.error
        console.log error

@currentPlayerEmails = ->
  if Meteor.user().emails?
    Meteor.user().emails.map (c) -> c.address
  else
    []

@currentPlayerId = -> Meteor.userId()

@currentPlayer = -> Meteor.user()

@currentGameId = -> Session.get 'currentGameId'

@currentGame = -> Games.findOne currentGameId()

@currentQuizId = -> currentGame().quizId

@currentQuiz = -> Quizzes.findOne currentQuizId()

@currentGameFinished = ->
  outOfQuestions = currentGame().currentQuestion >= numberOfQuestions()
  outOfQuestions or currentGame().state is 'finished'

@currentChallenge = ->
  Challenges.findOne $or: [
    { challengerGameId: currentGameId() }
  , { challengeeGameId: currentGameId() }
  ]

@currentChallengeId = -> currentChallenge()._id

@currentQuestionId = ->
  i = Session.get 'currentQuestion'
  currentQuiz().questionIds[i]

@currentQuestion = ->
  failIfNull Questions.findOne(currentQuestionId()),
    "Current question not found (id: #{currentQuestionId()})"

@numberOfQuestions = ->
  Quizzes.findOne(currentGame().quizId).questionIds.length

@currentAudioSrc = ->
  sound = Sounds.findOne currentQuestion().soundId
  "/audio/#{sound.segment}"


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
    $head.find("meta[name='description']").text(data.description)

  if data.og
    for k in Object.keys(data.og)
      $elem = $("meta[property='og:"+k+"']")

      if $elem.length is 0
        $("<meta>", { property: 'og:'+k, content: data.og[k] }).appendTo 'head'
      else
        $elem.attr('content',data.og[k])
