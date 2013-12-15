# Server side - game logic

# Settings
NUMBER_OF_QUESTIONS = 5
TIME_PER_QUESTION   = 30
START_POINTS        = 1000

# Methods
Meteor.methods
  keepalive: (player_id) ->
    # check player_id
    return unless player_id

    Players.update({ _id: player_id },
      { $set: {
          last_keepalive: (new Date()).getTime()
          idle: false
        }
      }
    )

  start_new_game: (player_id) ->
    # check player_id
    return unless player_id

    # TODO: Avoid getting the same questions
    questions = Questions.find({}, {limit: 5}).fetch()

    game_id = Games.insert
      current_points: START_POINTS
      current_question: 1
      question_ids: questions.map (q) -> q._id
      time_per_question: TIME_PER_QUESTION

    Players.update({ _id: player_id },
      { $set: { game_id: game_id } }
    )

    points_per_question = START_POINTS / NUMBER_OF_QUESTIONS
    points_per_second   = points_per_question / TIME_PER_QUESTION

#    for question_number in [1..NUMBER_OF_QUESTIONS]
#      clock = TIME_PER_QUESTION
#
#      # When question is answered, stop timer
#      #Games.findOne(game_id).answered
#
#      interval = Meteor.setInterval ->
#        clock--
#        Games.update({ _id: game_id },
#          { $set: {
#              current_question: question_number
#              current_points: clock * points_per_second
#              clock: clock
#            }
#          }
#        )
#      , 1000
