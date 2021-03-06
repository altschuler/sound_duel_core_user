# app/lib/router.coffee

Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'
  waitOn: ->
    [
      Meteor.subscribe 'currentUser'
      Meteor.subscribe 'users'
    ]


# filters

Router._filters =
  ganalytics: (pause) -> GAnalytics.pageview()

  isLoggedIn: (pause) ->
    loginRedirectKey = 'loginRedirect'

    if Meteor.loggingIn()
      pause()

    else unless Meteor.userId()?
      if Router.current().path != '/'
        Session.set loginRedirectKey, Router.current().path

      @redirect 'login'
      FlashMessages.sendWarning 'Du er ikke logget ind'
      pause()

    else
      loginRedirect = Session.get loginRedirectKey

      # redirect user to where he came from
      if loginRedirect and loginRedirect != 'logout'
        Session.set loginRedirectKey, null
        @redirect loginRedirect
        pause()

  isLoggedOut: (pause) ->
    if Meteor.userId()?
      FlashMessages.sendWarning 'Du er allerede logget ind'
      @redirect 'lobby'
      pause()

filters = Router._filters


# client

if Meteor.isClient

  # before hooks

  Router.onBeforeAction 'loading'
  Router.onBeforeAction 'dataNotFound',
    only: [ 'game', 'quiz' ]
  Router.onBeforeAction filters.isLoggedIn,
    only: [ 'logout', 'duel', 'quiz', 'lobby' ]
  Router.onBeforeAction filters.isLoggedOut,
    only: [ 'login', 'signup' ]

  # after hooks

  #Router.onAfterAction filters.ganalytics, except: 'game'


  # routes

  Router.map ->
    # lobby
    @route 'lobby',
      path: '/'

      waitOn: ->
        if Meteor.user()?
          [
            Meteor.subscribe 'challenges'
            Meteor.subscribe 'games'
          ]

    # data
    @route 'data'

    # highscore
    @route 'highscores',
      waitOn: ->
        [
          Meteor.subscribe 'quizzes'
          Meteor.subscribe 'highscores'
          Meteor.subscribe 'games'
          Meteor.subscribe 'overallhighscores'
          Meteor.subscribe 'challenges'
        ]

    # game types
    @route 'duel',
      waitOn: ->
        [
          Meteor.subscribe 'challenges'
          Meteor.subscribe 'games'
        , Meteor.subscribe 'highscores'
        ]

    # game
    @route 'quiz',
      path: '/quiz/:_id'

      onRun: ->
        id = @params._id
        Deps.nonreactive ->
          Session.set 'sharedQuizId', id

      waitOn: ->
        [
          Meteor.subscribe 'games'
          Meteor.subscribe 'challenges'
          Meteor.subscribe 'quizzes'
          Meteor.subscribe 'questions'
          Meteor.subscribe 'sounds'
        ]

      data: -> Quizzes.findOne @params._id

    # quizzes # TODO: testing
    @route 'quizzes',
      waitOn: -> Meteor.subscribe 'quizzes'

    # game
    @route 'game',
      path: '/game/:_id/:action'

      waitOn: ->
        [
          Meteor.subscribe 'games'
          Meteor.subscribe 'challenges'
          Meteor.subscribe 'quizzes'
          Meteor.subscribe 'questions'
          Meteor.subscribe 'sounds'

          # Meteor.subscribe 'currentGame', @params._id
          # Meteor.subscribe 'currentQuiz', @params._id
          # Meteor.subscribe 'currentQuizQuestions', @params._id
          # Meteor.subscribe 'currentQuizSounds', @params._id
          # Meteor.subscribe 'currentQuizHighscores', @params._id
        ]

      data: -> Games.findOne @params._id

      onRun: ->
        id = @params._id
        Deps.nonreactive ->
          Session.set 'currentGameId', id

      onBeforeAction: (pause) ->
        switch @params.action
          when 'play'
            unless Meteor.userId()
              @redirect 'login'
              FlashMessages.sendWarning 'Du er ikke logget ind'
              pause()

          when 'result' then break

          else
            @render 'notFound'
            pause()

      action: ->
        @render @params.action

    # session
    @route 'login'

    @route 'signup'

    @route 'logout',
      action: ->
        id = Meteor.userId()

        Meteor.logout (err) =>
          if err?
            FlashMessages.sendError 'Kunne ikke logge ud'
            console.log err
            @redirect 'lobby'
          else
            Meteor.call 'logoutUser', id, (err) ->
              console.log err if err?
            FlashMessages.sendSuccess 'Logget ud'
            @redirect 'login'

else if Meteor.isServer
  Router.map ->
    # data dump
    @route 'dump',
      path: '/dump'
      where: 'server'
      action: ->
        games = Games.find({state:'finished'}).map (game) ->
          gameId: game.gameId
          answers: _.map game.answers, (a) ->
            _.pick(a, 'questionId', 'answer', 'isFree')

        questions = Questions.find({}, fields:{_id: 1, alternatives: 1}).fetch()

        @response.setHeader 'Content-Type', 'application/json; charset=utf-8'
        @response.end JSON.stringify(games: games, questions: questions)
