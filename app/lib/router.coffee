# app/lib/router.coffee

# client

if Meteor.isClient

  Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'notFound'

  Router.map ->
    # lobby
    @route 'lobby', path: '/'

    # highscore
    @route 'highscores'

    #game types
    @route 'single', path: '/single'
    @route 'duel', path: '/duel'

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
            # TODO: This should render an error message that the user is already
            #       playing a different quiz
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

      onRun: ->
        id = @params._id
        Deps.nonreactive ->
          Session.set 'gameId', id

      action: ->
        @render @params.action

  loginRedirectKey = 'loginRedirect'
  Router.onBeforeAction( (pause) ->
    if Meteor.loggingIn()
      console.log("Logging in")
      pause()
    else if not Meteor.userId()
      console.log("Not logged in")
      if Router.current().path isnt '/'
        Session.set(loginRedirectKey, Router.current().path)
      this.redirect 'login'
      pause()
    else
      loginRedirect = Session.get(loginRedirectKey)
      #Redirect user to where he came from
      if(loginRedirect)
        console.log("Redirecting")
        Session.set(loginRedirectKey,null)
        this.redirect loginRedirect
        pause()
      console.log("Logged in as:")
      console.log(Meteor.user())
  , {except: 'login', 'result'})
