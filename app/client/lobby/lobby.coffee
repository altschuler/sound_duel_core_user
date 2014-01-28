# app/client/lobby/lobby.coffee

# helpers

Template.lobby.helpers
  disabled: ->
    if not current_guest() or current_guest == '' then 'disabled="disabled"'

Template.players.helpers
  waiting: ->
    count = online_players().length
    if count == 0
      "Ingen spillere online"
    else if count == 1
      "1 spiller online:"
    else
      "#{count} spillere der er online:"


# events

Template.lobby.events
  'keyup input#name': (event, template) ->
    if event.keyCode is 13
      $('#new_game').click()
    else
      # get name and remove ws
      name = template.find('input#name').value.replace /^\s+|\s+$/g, ""
      Session.set 'guest', name

  'click button#new_game': (event, template) ->
    Meteor.call 'new_game', Meteor.userId(), (error, result) ->
      Session.set 'game_id', result

      force_play_audio 'audio.asset:first', (element) ->
        Questions.update current_question_id(),
          $set: { 'answerable': true }

      Meteor.Router.to "/games/#{current_game_id()}/play"
