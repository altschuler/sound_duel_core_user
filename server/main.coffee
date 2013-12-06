fs = Npm.require("fs")

# Settings
IDLE_TRESHOLD       = 70*1000 # X s * 1000 ms/s
REMOVE_TRESHOLD     = 70*1000 # X s * 1000 ms/s

AUDIO_DIR = '../client/app/audio/'
SAMPLE_DATA = 'sample_data.json'


refresh_db = ->
  console.log "Refreshing db.."

  # Clear database
  # TODO: Only for development
  @Players.remove({})
  @Games.remove({})
  @Questions.remove({})
  @Sounds.remove({})

  # Get audiofiles from /public
  audio_files = fs.readdirSync(AUDIO_DIR).filter (file) ->
    ~file.indexOf('.mp3')

  sample_questions = JSON.parse(Assets.getText SAMPLE_DATA)

  # Populate database
  for sample in sample_questions
    #console.log sample.soundfile_prefix + ":"

    question_id = @Questions.insert(sample)

    segments = audio_files.filter (file) ->
      ~file.indexOf(sample.soundfile_prefix)

    sound_id = @Sounds.insert({segments: segments})

    @Questions.update(question_id, {$set: {sounds: sound_id}})

    #console.log @Questions.findOne question_id
    #console.log @Sounds.findOne sound_id


  console.log "#Questions: " + @Questions.find().count()
  console.log "#Sounds: " + audio_files.length


# Initialize
Meteor.startup ->
  refresh_db()


# Update players to idle with keepalive
# and remove long tidling players
Meteor.setInterval ->
  now = (new Date()).getTime()
  idle_threshold = now - IDLE_TRESHOLD
  remove_threshold = now - REMOVE_TRESHOLD

  # Set players to idle
  Players.update(
    { last_keepalive: { $lt: idle_threshold } },
    { $set: { idle: true } })

  # Remove idling players
  Players.remove $lt: { last_keepalive: remove_threshold }

, 30*1000
