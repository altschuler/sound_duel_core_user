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

Template.progress.width = ->
  #audio = $("#audio")[0]
  ##console.log audio.duration # duration, in seconds
  #
  #start_points = current_game().current_points
  #points_per_second = start_points / audio.duration
  #
  #clock = parseInt audio.duration, 10
  #
  #progress = Meteor.setInterval(->
  #  $bar = $(".bar")
  #
  #  if $bar.width() <= 0
  #    Meteor.clearInterval progress
  #    $(".progress").removeClass "active"
  #  else
  #    $bar.width (clock * 100) / audio.duration
  #
  #  $bar.text clock * points_per_second
  #, 10)

  #current_game().clock

Template.progress.text = ->
  Math.floor current_game().current_points

Template.audio.rendered = ->
  $audio = $('#audio')[0]
  $audio.play()
  interval = setInterval( ->
    value = $audio.currentTime / $audio.duration
    $('#bar').attr 'aria-valuenow', value
    $('#bar').attr 'style', "width: " + value + "%"
  , 1)
