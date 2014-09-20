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
    only: [ 'logout', 'duel', 'quiz' ]
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

    # highscore
    @route 'highscores',
      waitOn: ->
        [
          Meteor.subscribe 'quizzes'
          Meteor.subscribe 'highscores'
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

    # quizzes # TODO: testing
    @route 'quizzes',
      waitOn: -> Meteor.subscribe 'quizzes'

    # quiz
    @route 'quiz',
      path: '/quiz/:_id'

      waitOn: ->
        [
          Meteor.subscribe 'games'
          Meteor.subscribe 'challenges'
          Meteor.subscribe 'quizzes'
          Meteor.subscribe 'questions'
          Meteor.subscribe 'sounds'
        ]

      data: ->
        Quizzes.findOne @params._id

      onRun: ->
        id = @params._id
        Deps.nonreactive ->
          Session.set 'currentQuizId', id

      onBeforeAction: (pause) ->
        quiz = @data()
        return unless quiz?

        # TODO: we're not doing date-based quizzes anymore, delete this?
        # Check that the quiz has started and hasn't run out
        # now = new Date()
        # unless (quiz.startDate < now and now < quiz.endDate)
        #   @redirect 'lobby'
        #   FlashMessages.sendError 'Denne quiz er ikke tilgængelig'
        #   pause()
        #   return

        unless Session.get 'currentQuestion'
          Session.set 'currentQuestion', 0

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
        unless @params.action in ['result']
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
