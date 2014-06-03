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
    if Meteor.user().profile
      Meteor.user().profile.name
    else
      Meteor.user().emails[0].address
