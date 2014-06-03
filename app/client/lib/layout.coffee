# app/client/utils/layout.coffee

# helpers
UI.registerHelper 'active', (route) ->
  currentRoute = Router.current()
  return '' unless currentRoute

  if currentRoute.route.name == route
    'active'
  else
    ''

Template.currentUser.helpers
  name: ->
    Meteor.user().profile.name
