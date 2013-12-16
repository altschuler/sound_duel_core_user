# Client
#

# Helpers

Handlebars.registerHelper 'app_name', -> "Målsuppe"

current_player = ->
  unless Session.get 'player_id'
    # Set player id to session
    player_id = @Players.insert { name: '', idle: false }
    Session.set 'player_id', player_id

  @Players.findOne Session.get 'player_id'

Handlebars.registerHelper 'current_player', current_player

current_game = ->
  player = current_player()
  if player and player.game_id
    @Games.findOne player.game_id
Handlebars.registerHelper 'current_game', current_game

Handlebars.registerHelper 'game_finished', ->
  current_game().finished

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

# Lobby

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
  #$('#myname').focus()

Template.lobby.events
  'keyup input#myname': (evt) ->
    if evt.keyCode is 13
      $('#startgame').click()
    else
      # Get name and remove ws
      name = $('input#myname').val().replace /^\s+|\s+$/g, ""
      @Players.update Session.get('player_id'), {$set: {name: name}}

  'click button#startgame': ->
    Meteor.call 'start_new_game', current_player()._id
    setTimeout( ->
      $('#audio').get(0).play()
    , 1000)


# Game

current_question = ->
  unless current_game().current_question >= current_game().question_ids.length
    @Questions.findOne current_game().question_ids[current_game().current_question]

Template.game.current_question = ->
  (current_game().current_question+1) + '/' + current_game().question_ids.length

random_segment = ->
  sound = @Sounds.findOne current_question().sound_id
  ran = Math.floor(Math.random() * sound.segments.length)
  "audio/" + sound.segments[ran]
Template.audio.sound_segment = random_segment

Template.alternatives.alternatives = ->
  current_question().alternatives

once = true
Template.game.rendered = ->
  # only run once
  if once then once = false else return

  $('#audio').bind 'timeupdate', ->
    value = 100 - (($('#audio')[0].currentTime * 100) / $('#audio')[0].duration)
    $('.bar').attr 'style', "width: " + value + "%"
    $('.bar').text Math.floor (current_game().points_per_question * value) / 100

Template.game.events
  'click a.alternative': (event) ->
    $('#audio')[0].pause()

    points = parseInt($('.bar').text(), 10)
    answer = event.target.text[0]

    Games.update current_game()._id,
      $addToSet:
        answers: {
          question_id: current_question()._id
          answer: answer
          points: points
        }
      $inc:
        current_question: 1

    unless current_question()
      Games.update current_game()._id,
        $set:
          finished: true
    else
      setTimeout( ->
        $('#audio').attr 'src', random_segment()
        $('#audio')[0].load()
        $('#audio')[0].play()
      , 1000)


Template.result.result = ->
  points = 0
  correct = 0
  total = current_game().question_ids.length
  for a in current_game().answers
    if a.answer is Questions.findOne(a.question_id).correct_answer
      correct++
      points += a.points

  { "points": points, "correct": correct + '/' + total }

Template.result.events
  'click a#restart': ->
    Session.set('player_id', '')
    location.reload()
