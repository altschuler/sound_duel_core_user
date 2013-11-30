fs = Npm.require("fs")
# (if (typeof (Npm) is "undefined") then __meteor_bootstrap__.require("fs") else Npm.require("fs"))

# Initialize

AUDIO_DIR = '../client/app/audio/'
SAMPLE_DATA = 'sample_data.json'

Meteor.startup ->
  console.log "Refreshing db.."

  # Clear database
  # TODO: Only for development
  @Players.remove({})
  @Games.remove({})
  @Questions.remove({})
  @Sounds.remove({})

  # Get audiofiles from /public
  audio_files = fs.readdirSync(AUDIO_DIR).filter( (file) ->
    ~file.indexOf('.mp3')
  )

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
