# Helper methods

@random_sound_segment = (sound_id) ->
  segments = @Sounds.findOne(sound_id).segments
  segments[Math.floor(Math.random() * segments.length)]
