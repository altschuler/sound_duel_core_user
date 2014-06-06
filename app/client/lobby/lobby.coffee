# app/client/lobby/lobby.coffee

# methods

handleUsernameError = (error) ->
  $('button#new-game').prop 'disabled', true
  if error.error is 409
    Session.set 'usernameError', error.reason
  else
    Session.set 'usernameError', 'Ops! Something bad happened.'
    throw error

# helpers

Template.lobby.helpers
  username: ->
    if Meteor.user().profile?
      Meteor.user().profile.name
    else
      Meteor.user().emails[0].address

  game_name: -> "Marco's Crazy VM spil"
