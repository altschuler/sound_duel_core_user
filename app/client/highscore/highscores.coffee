# app/client/highscore/highscores.coffee

todayDate = new Date()

# helpers

Template.highscores.helpers
  highscores: ->

    search_obj =
      score: { $gt: 0 }
      # state: { $eq: 'finished' }

    # The `state == 'finished'` criteria is not used, because
    #  1. When there's no games in the database Minimongo breaks on this query
    #  2. Only finished games have a score greater than zero

    if Session.get 'quizId'
      Games.find(
        score: { $gt: 0 }
        quizId: Session.get 'quizId'
      , { sort: [['score', 'desc']], limit: 20 })
      # Highscores.find(
      #   score: { $gt: 0 }
      #   quizId: Session.get 'quizId'
      # )
    else
      null
      #OverallHighscores.find()
      # Games.find(
      #   score: { $gt: 0 }
      # , { sort: [['score', 'desc']], limit: 20 })



  quizzes: ->
    today = new Date()
    Quizzes.find(
      startDate: { $lt: today}
    ,
      sort: [['startDate', 'asc']]
    ).fetch()

Template.highscores.events
  # <select> change quiz
  'change ': (event) ->
    console.log '<select> changed'
    quizId = $('[data-sd-quiz-selector] option:selected').data('quiz-id')
    Session.set 'quizId', quizId
    console.log(Session.get 'quizId')

UI.registerHelper 'selectToday', (date) ->
  if todayDate.setHours(0,0,0,0) == date.setHours(0,0,0,0)
    ' selected="selected"'
  else
    ''

UI.registerHelper 'displayDate', (date) ->
  months = ['januar', 'februar', 'marts', 'april', 'maj', 'juni', 'juli',
    'august', 'september', 'oktober', 'november', 'december']
  date.getDate() + '. ' + months[date.getMonth()]

UI.registerHelper 'playerUsername', (playerId) ->
  player = Meteor.users.findOne(playerId)
  if player then player.profile.name else '?'

UI.registerHelper 'withPosition', (cursor, options) ->
  cursor.map (element, i) ->
    element.position = i + 1
    element
