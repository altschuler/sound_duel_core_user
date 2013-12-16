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

Template.lobby.rendered = ->
  $('#myname').focus()

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


Template.game.current_question = ->
  current_game().current_question + '/' + current_game().question_ids.length

current_question = ->
  @Questions.findOne current_game().question_ids[current_game().current_question]
Template.game.question = current_question

Template.audio.sound_segment = ->
  sound = @Sounds.findOne current_question().sound_id
  ran = Math.floor(Math.random() * sound.segments.length)
  "audio/" + sound.segments[ran]

Template.alternatives.alternatives = ->
  current_question().alternatives

once = true
Template.game.rendered = ->
  # only run once
  if once then once = false else return

  #if $('.bar').css('visibility','hidden').is(':hidden')
  #  $('#play').show()
  #else
  #  $('#play').hide()

  #answered = false
  #for a in current_game().answers
  #  answered = true if a.question_id is current_question()._id

  #unless $('#audio')[0].paused
  $('#audio').bind 'timeupdate', ->
    value = 100 - (($('#audio')[0].currentTime * 100) / $('#audio')[0].duration)
    $('.bar').attr 'style', "width: " + value + "%"
    $('.bar').text Math.floor (current_game().points_per_question * value) / 100

  $('#play').bind 'click', (event) ->
    $('#audio')[0].play()
    $('.progress').show()
    $(event.target).hide()

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


    console.log current_question().correct_answer == answer, points
    console.log current_game().answers
