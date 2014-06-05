# app/lib/router.coffee

Router.configure
  layoutTemplate: 'layout'
  loadingTemplate: 'loading'
  notFoundTemplate: 'notFound'


# filters

Router._filters =
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
  Router.onBeforeAction filters.isLoggedIn, only: [ 'logout', 'lobby', 'quiz' ]
  Router.onBeforeAction filters.isLoggedOut, only: [ 'login', 'signup' ]


  # routes

  Router.map ->
    # lobby
    @route 'lobby', path: '/'

    # highscore
    @route 'highscores'

    #game types
    @route 'single'
    @route 'duel'

    # DEBUG route
    @route 'quizzes', path: '/quizzes/'

    # quiz
    @route 'quiz',
      path: '/quiz/:_id/'

      onBeforeAction: (pause) ->

        # Find the quiz
        quizId = @params._id
        quiz = Quizzes.findOne quizId
        unless quiz?
          @render 'notFound'
          pause()
          return

        # Check that the quiz has started and hasn't run out
        now = new Date()
        unless (quiz.startDate < now and now < quiz.endDate)
          @render 'notAvailable'
          pause()
          return

        # Check if player is already playing a quiz
        currentQuizId = Session.get('currentQuizId')
        if currentQuizId?
          # player is already playing a quiz
          if currentQuizId != @params._id
            # TODO: This should render an error
            # message that the user is already playing a different quiz
            @render 'notFound'
            pause()
        else
          Session.set('currentQuizId', quizId)

        unless Session.get 'currentQuestion'
          Session.set 'currentQuestion', 0

    # game
    @route 'game',
      path: '/game/:_id/:action'

      data: ->
        Games.findOne @params._id

      onBeforeAction: (pause) ->
        unless @params.action in ['result']
          @render 'notFound'
          pause()

        unless @data()?
          @render 'notFound'
          pause()

      waitOn: ->
        Meteor.subscribe 'games'
        Meteor.subscribe 'quizzes'

      onRun: ->
        id = @params._id
        Deps.nonreactive ->
          Session.set 'gameId', id

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
