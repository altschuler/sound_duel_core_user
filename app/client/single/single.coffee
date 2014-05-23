# app/client/single/single.coffee

# methods

# helpers

# Template.single.helpers
#   username: ->
#     Meteor.user().profile.name

#   usernameError: -> Session.get 'usernameError'

#   usernameDisabled: ->
#     'disabled' if currentPlayer()?

#   newGameDisabled: ->
#     'disabled' unless currentPlayer()?

# events

Template.single.events
  'click .js-start-game': (event) ->

    # Find the quiz of the day
    now = new Date()
    quiz_of_the_day = Quizzes.find(
      startDate: {$lt: now}
      endDate:   {$gt: now}
    , {limit: 1}).fetch()[0]

    # Create the game, and go to the quiz view
    Meteor.call 'newGame', currentPlayerId(), {}, (error, result) ->
      Session.set 'currentQuestion', 0
      Session.set 'gameId', result.gameId
      Router.go 'quiz', _id: quiz_of_the_day._id
