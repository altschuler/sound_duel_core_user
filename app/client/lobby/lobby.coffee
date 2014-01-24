# app/client/lobby/lobby.coffee

# helpers

Template.lobby.disabled = ->
  if current_player() and current_player().name is '' then 'disabled="disabled"'

Template.players.helpers
  waiting: ->
    count = player_count()
    if count == 0
      "Ingen spillere der venter"
    else if count == 1
      "1 spiller der venter:"
    else
      count + " spillere der venter:"

Handlebars.registerHelper 'idle', (player) ->
  if player.idle then "style=color:grey"


# events

Template.lobby.events
  'keyup input#name': (event, template) ->
    if event.keyCode is 13
      $('#new_game').click()
    else
      # get name and remove ws
      name = template.find('input#name').value.replace /^\s+|\s+$/g, ""
      Players.update Session.get('player_id'), { $set: { name: name } }

  'click button#new_game': (event, template) ->
    force_play_audio 'audio.asset:first', (element) -> 
      Questions.update current_question()._id, {
        $set: { 'answerable': true }
      }
    Meteor.call 'new_game', current_player()._id, (error, result) ->
      Meteor.Router.to "/games/#{current_player().game_id}/play"