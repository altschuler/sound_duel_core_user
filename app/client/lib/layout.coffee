# app/client/utils/layout.coffee

# helpers
UI.registerHelper 'active', (route) ->
  currentRoute = Router.current()
  return '' unless currentRoute

  if currentRoute.route.name == route
    'active'
  else
    ''

# Template.currentPlayer.rendered = ->
#   Accounts._loginButtonsSession.set('dropdownVisible', true)

# events
Template.currentUser.events
  'click #logout': (event) ->
    Meteor.logout (err) ->
      if err?
        FlashMessages.sendError 'Kunne ikke logge ud'
        console.log err
      else
        FlashMessages.sendSuccess 'Logget ud'
