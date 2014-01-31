# app/client/lobby/lobby.coffee

# helpers

Template.lobby.helpers
  disabled: ->
    # name = "#{$('input#name').val()}"
    # # if not currentPlayer() or currentPlayer.username == '' then 'disabled'
    # if !!name then 'disabled'

Template.players.helpers
  waiting: ->
    count = onlinePlayers().length
    if count == 0
      "Ingen spillere online"
    else if count == 1
      "1 spiller online:"
    else
      "#{count} spillere der er online:"


# rendered

Template.lobby.rendered = ->
  if !!"#{$('input#name').val()}"
    $('input#name').val currentPlayer().username


# events

Template.lobby.events
  'keyup input#name': (event, template) ->
    if event.keyCode is 13
      $('#new-game').click()
    # else
    #   name = "#{$('input#name').val()}"
    #   if !!name
    #     $('btn#new-game').attr 'disabled', 'disabled'
    #   else
    #     $('btn#new-game').removeAttr 'disabled'

      # get name and remove ws
        # name = template.find('input#name').value.replace /^\s+|\s+$/g, ""
      # update current player name
      # Meteor.users.update currentPlayerId(),
      #   $set: { username: name }

  'click button#new-game': (event, template) ->
    name = template.find('input#name').value.replace /^\s+|\s+$/g, ""

    newPlayer name, (id) ->

      Meteor.call 'newGame', currentPlayerId(), (error, result) ->
        Session.set 'gameId', result

        forcePlayAudio 'audio.asset:first', (element) ->
          Questions.update currentQuestionId(),
            $set: { answerable: true }

        Meteor.Router.to "/games/#{currentGameId()}/play"
