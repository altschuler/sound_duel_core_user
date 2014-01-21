# app/server/game.coffee

# methods

Meteor.methods
  keepalive: (player_id) ->
    # check player_id
    return unless player_id

    Players.update player_id,
      $set:
        last_keepalive: (new Date()).getTime()
        idle: false

  new_game: (player_id) ->
    # check player_id
    return unless player_id

    # TODO: avoid getting the same questions
    questions = Questions.find({}, {limit: 5}).fetch()

    game_id = Games.insert
      points_per_question: CONFIG.POINTS_PER_QUESTION
      question_ids: questions.map (q) -> q._id
      current_question: 0
      answers: []

    Players.update player_id,
      $set:
        game_id: game_id
