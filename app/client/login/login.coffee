# app/client/login/login.coffee


# events
Template.login.events
  'click button[data-login]': ->
    Meteor.loginWithFacebook (err) ->
      if err
        console.log('An error occurred while logging in with facebook')
        console.log(err)
      else
        console.log('You successfully logged in!')
        Router.go('lobby')
