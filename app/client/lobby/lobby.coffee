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


# rendered

Template.lobby.rendered = ->
  #$('#myname').focus() # TODO: Fix


# events

Template.lobby.events
  'keyup input#myname': (event, template) ->
    if event.keyCode is 13
      $('#new_game').click()
    else
      # get name and remove ws
      name = template.find('input#myname').value.replace /^\s+|\s+$/g, ""
      Players.update Session.get('player_id'), { $set: { name: name } }

  'click button#new_game': (event, template) ->
    Meteor.call 'new_game', current_player()._id, (error, result) ->
      Meteor.Router.to "/games/#{current_player().game_id}/play"

      # audioElementsCount = $("audio").length
      # audioElementsLoaded = 0

      # http://www.w3schools.com/tags/av_event_canplaythrough.asp
      # for $audio in $('audio')
      #   $audio[0].bind canplaythrough, ->
      #     audioElementsLoaded++

      #     if audioElementsLoaded >= audioElementsCount
            # Start the game!
            #$("audio:first")[0].play()

      # while true
      #   if audio_loaded() >= current_game().question_ids.length
      #     setTimeout ->
      #       $('audio#0')[0].play()
      #     , 1000
      #     return
