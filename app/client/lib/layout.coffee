# app/client/utils/layout.coffee

# helpers
UI.registerHelper 'active', (route) ->
  currentRoute = Router.current()
  return '' unless currentRoute

  if currentRoute.route.name == route
    'active'
  else
    ''
