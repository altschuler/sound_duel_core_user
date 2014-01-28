# app/server/game.coffee

# methods

Meteor.methods
  keepalive: (player_id) ->
    # check player_id
    return unless player_id

    Meteor.users.update player_id,
      $set:
        last_keepalive: (new Date()).getTime()
        online: true

  new_game: (player_id) ->
    # TODO: avoid getting the same questions
    questions = Questions.find({}, {limit: 5}).fetch()

    game_id = Games.insert
      points_per_question: CONFIG.POINTS_PER_QUESTION
      question_ids: questions.map (q) -> q._id
      current_question: 0
      answers: []

    if player_id then Meteor.users.update player_id,
      $set:
        game_id: game_id

    game_id
