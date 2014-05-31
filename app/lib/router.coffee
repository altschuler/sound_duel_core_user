# app/lib/router.coffee

# client

if Meteor.isClient

  Router.configure
    layoutTemplate: 'layout'
    notFoundTemplate: 'notFound'

  Router.map ->
    # login
    @route 'login',
      onBeforeAction: (pause) ->
        if Meteor.userId()
          console.log("Visiting login while logged in")
          this.redirect 'lobby'

    # lobby
    @route 'lobby', path: '/'

    # highscore
    @route 'highscores'

    #game types
    @route 'single', path: '/single'
    @route 'duel', path: '/duel'

    # session
    @route 'session',
      path: '/session/:action'

      onBeforeAction: (pause) ->
        unless @params.action in ['logout']
          @render 'notFound'
          pause()

      action: ->
        switch @params.action
          when 'logout'
            id = localStorage.getItem 'playerId'
            Meteor.call 'logoutPlayer', id, (err, res) =>
              if err
                throw err
              else
                localStorage.removeItem 'playerId'

    # game
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

      onBeforeAction: (pause) ->
        unless @params.action in ['result']
          @render 'notFound'
          pause()

        gameId = @params._id
        game = null
        Deps.nonreactive ->
          game = Games.findOne gameId
        if not game? #or game.state is 'inprogress'
          @render 'notFound'
          pause()

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
      if(loginRedirect)
        console.log("Redirecting")
        Session.set(loginRedirectKey,null)
        this.redirect loginRedirect
        pause()
      console.log("Logged in as:")
      console.log(Meteor.user())
  , {except: 'login'})
