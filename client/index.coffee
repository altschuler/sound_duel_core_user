# Client
#

# Helpers

Handlebars.registerHelper 'app_name', -> "Målsuppe"

current_player = -> @Players.findOne Session.get('player_id')
Handlebars.registerHelper 'current_player', current_player

current_game = ->
  player = current_player()
  if player and player.game_id
    @Games.findOne player.game_id
Handlebars.registerHelper 'current_game', current_game

players = ->
  @Players.find({
    _id:     { $ne: Session.get('player_id') },
    name:    { $ne: '' },
    game_id: { $exists: false }
  }).fetch()
Handlebars.registerHelper 'players', players

player_count = ->
  players().length
Handlebars.registerHelper 'player_count', player_count


# Templates

Template.lobby.disabled = ->
  if current_player() and current_player().name == '' then 'disabled="disabled"'

Template.players.waiting = ->
  if player_count() == 0
    "Ingen spillere der venter"
  else if player_count() == 1
    "1 spiller der venter:"
  else
    player_count() + " spillere der venter:"

Template.lobby.events
  'keyup input#myname': (evt) ->
    # Get name and remove ws
    name = $('input#myname').val().replace /^\s+|\s+$/g, ""
    @Players.update Session.get('player_id'), {$set: {name: name}}

  'click button#startgame': ->
    Meteor.call 'start_new_game', current_player()._id


Template.game.current_question = ->
  current_game().current_question + '/' + current_game().question_ids.length

Template.game.current_points = ->
  Math.floor current_game().current_points

current_question = ->
  @Questions.findOne current_game().question_ids[current_game().current_question]
Template.game.question = current_question

Template.audio.sound_segment = ->
  sound = @Sounds.findOne current_question().sound_id
  ran = Math.floor(Math.random() * sound.segments.length)
  "audio/" + sound.segments[ran]

Template.audio.rendered = ->
  $audio = $('#audio')
  audio = $audio[0]

  $audio.bind 'timeupdate', ->
    value = 100 - ((audio.currentTime * 100) / audio.duration)
    $('.bar').attr 'aria-valuenow', value
    $('.bar').attr 'style', "width: " + value + "%"
    $('.bar').text Math.floor (current_game().current_points * value) / 100

  #if audio.currentTime is 0 then audio.play()

  $('#play').bind 'click', (event) ->
    $('#audio')[0].play()
    $('.progress').show()
    $(event.target).hide()
