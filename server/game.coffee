# Server side - game logic

# Settings
NUMBER_OF_QUESTIONS = 5
TIME_PER_QUESTION   = 30
START_POINTS        = 1000

# Methods
Meteor.methods
  keepalive: (player_id) ->
    # check player_id
    return if not player_id

    Players.update({ _id: player_id },
      { $set: {
          last_keepalive: (new Date()).getTime()
          idle: false
        }
      }
    )

  # Method call is commented out in the bottom of 'client/index.coffee'
  start_new_game: ->
    # TODO: Avoid getting the same questions
    questions = @Questions.find limit: 5

    game_id = @Games.insert
      points: START_POINTS
      questions: questions

    player_id = Session.get 'player_id'

    Players.update({ _id: player_id },
      { $set: { game_id: game_id } }
    )

    points_per_question = START_POINTS / NUMBER_OF_QUESTION
    points_per_second   = points_per_question / TIME_PER_QUESTION

    # WIP: Where I left off
    for question_number in [1..NUMBER_OF_QUESTIONS]
      clock = TIME_PER_QUESTION

      # When question is answered, stop timer
      Games.findOne(game_id).answered

      internval = Meteor.setInterval ->
        clock--
        @Games.update({ _id: game_id },
          { $set: {
              question_number: question_number
              clock: clock
            }
          }
        )
