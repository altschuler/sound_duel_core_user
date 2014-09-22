# app/client/highscore/highscores.coffee

# helpers

Template.highscores.helpers
  highscores: ->
    Games.find
      score: { $gt: 0 }
    ,
      sort: [[ 'score', 'desc' ]]
      limit: 20
      fields: { _id: 1 }
    .map (game) ->
      Highscores.findOne gameId: game._id

UI.registerHelper 'username', (userId) ->
  user = Meteor.users.findOne userId
  if user then user.profile.name else '?'

UI.registerHelper 'gameScore', (gameId) ->
  game = Games.findOne gameId
  if game then game.score else '?'

UI.registerHelper 'withPosition', (cursor, options) ->
  cursor.map (element, i) ->
    element.position = i + 1
    element
