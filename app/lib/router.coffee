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

    # session
    @route 'session',
      path: '/session/:action'

      onBeforeAction: (pause) ->
        unless this.params.action in ['logout']
          @render 'notFound'
          pause()

      action: ->
        switch this.params.action
          when 'logout'
            localStorage.removeItem 'playerId'
        @redirect '/'

    # game
    @route 'game',
      path: '/game/:_id/:action'

      onBeforeAction: (pause) ->
        unless this.params.action in ['play', 'result']
          @render 'notFound'
          pause()

      data: ->
        Games.findOne this.params._id

      action: ->
        Session.set 'gameId', this.params._id

        @render this.params.action
