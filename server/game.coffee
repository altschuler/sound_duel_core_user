# server-side
# game logic

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
      points_per_question: CONFIG.START_POINTS
      question_ids: questions.map (q) -> q._id
      current_question: 0
      answers: []

    Players.update player_id,
      $set:
        game_id: game_id
