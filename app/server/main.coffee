# app/server/main.coffee

fs = Npm.require 'fs'


# methods

refresh_db = ->
  console.log "Refreshing db.."

  # clear database
  # TODO: only for development
  Players.remove({})
  Games.remove({})
  Questions.remove({})
  Sounds.remove({})

  # get audiofiles from /public
  audio_files = fs.readdirSync(CONFIG.ASSETS_DIR).filter (file) ->
    ~file.indexOf('.mp3')

  sample_questions = JSON.parse(Assets.getText CONFIG.SAMPLE_DATA)

  # populate database
  for sample in sample_questions
    question_id = Questions.insert(sample)

    segments = audio_files.filter (file) ->
      ~file.indexOf(sample.soundfile_prefix)

    sound_id = Sounds.insert segments: segments

    Questions.update question_id,
      $set: { sound_id: sound_id }

  # print some info
  console.log "#Questions: " + Questions.find().count()
  console.log "#Sounds: " + audio_files.length


# initialize

Meteor.startup ->
  refresh_db()

  # update players to idle with keepalive
  # and remove long idling players
  Meteor.setInterval ->
    now = (new Date()).getTime()
    idle_threshold = now - CONFIG.IDLE_TRESHOLD
    remove_threshold = now - CONFIG.REMOVE_TRESHOLD

    # set players to idle
    Players.update last_keepalive: { $lt: idle_threshold },
      $set: { idle: true }

    # remove idling players
    Players.remove $lt: { last_keepalive: remove_threshold }

  , CONFIG.IDLE_TRESHOLD
