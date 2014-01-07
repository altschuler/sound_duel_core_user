# client/lobby/lobby.coffee

Template.lobby.disabled = ->
  if current_player() and current_player().name is '' then 'disabled="disabled"'

Template.players.waiting = ->
  if player_count() == 0
    "Ingen spillere der venter"
  else if player_count() == 1
    "1 spiller der venter:"
  else
    player_count() + " spillere der venter:"

Template.lobby.rendered = ->
  #$('#myname').focus() # TODO: Fix

Template.lobby.events
  'keyup input#myname': (evt) ->
    if evt.keyCode is 13
      $('#startgame').click()
    else
      # get name and remove ws
      name = $('input#myname').val().replace /^\s+|\s+$/g, ""
      @Players.update Session.get('player_id'), {$set: {name: name}}

  'click button#startgame': ->
    Meteor.call 'start_new_game', current_player()._id
    setTimeout( ->
      $('#audio').get(0).play()
    , 1000)
