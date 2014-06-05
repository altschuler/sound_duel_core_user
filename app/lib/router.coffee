# app/lib/router.coffee

# client

if Meteor.isClient

  Router.configure
    layoutTemplate:   'layout'
    notFoundTemplate: 'notFound'
    loadingTemplate: 'loading'

  # login redirect filter

  loginRedirectKey = 'loginRedirect'
  Router.onBeforeAction 'loading'
  Router.onBeforeAction (pause) ->

    if Meteor.loggingIn()
      console.log "Logging in"
      pause()

    else if not Meteor.userId()?
      console.log "Not logged in"

      if Router.current().path isnt '/'
        Session.set loginRedirectKey, Router.current().path

      @redirect 'login'
      pause()

    else
      loginRedirect = Session.get loginRedirectKey

      # redirect user to where he came from
      if loginRedirect and loginRedirect != 'logout'
        console.log "Redirecting"
        Session.set loginRedirectKey, null
        @redirect loginRedirect
        pause()

  , { except: ['login', 'logout', 'signup', 'game', 'highscores'] }

  Router.map ->
    # lobby
    @route 'lobby', path: '/'

    # highscore
    @route 'highscores'

    #game types
    @route 'single', path: '/single'
    @route 'duel', path: '/duel'


    # DEBUG route
    @route 'quizzes',
      path: '/quizzes/'

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
        if not (quiz.startDate < now and now < quiz.endDate)
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

        if not Session.get('currentQuestion')
          Session.set('currentQuestion', 0)

    # game
    @route 'game',
      path: '/game/:_id/:action'

      data: ->
        Games.findOne @params._id

      onBeforeAction: (pause) ->
        unless @params.action in ['result']
          @render 'notFound'
          pause()

        if not this.data()?#or game.state is 'inprogress'
          @render 'notFound'
          pause()

        # gameId = @params._id
        # game = null
        # Deps.nonreactive ->
        #   game = Games.findOne gameId
        #   console.log game
        # if not game? #or game.state is 'inprogress'
        #   @render 'notFound'
        #   pause()

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
    @route 'signup',
      onBeforeAction: (pause) ->
        if Meteor.userId()?
          FlashMessages.sendWarning 'Du er allerede logget ind'
          @redirect 'lobby'
          pause()

    @route 'login',
      onBeforeAction: (pause) ->
        if Meteor.userId()?
          FlashMessages.sendWarning 'Du er allerede logget ind'
          @redirect 'lobby'
          pause()

    @route 'logout',
      onBeforeAction: (pause) ->
        unless Meteor.userId()?
          FlashMessages.sendError 'Du er ikke logget ind'
          @redirect 'login'
          pause()

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
