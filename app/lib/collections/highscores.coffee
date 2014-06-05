# app/client/lib/collections/highscores.coffee

@Highscores = new Meteor.Collection 'highscores'

# permission

# TODO

# publish

if Meteor.isServer
  Meteor.publish 'highscores', (args) ->
    # From: http://stackoverflow.com/a/18884223/118608

    # Highscores.find()
    sub = this
    # This works for Meteor 0.6.5
    db = MongoInternals.defaultRemoteCollectionDriver().mongo.db

    console.log args

    # Your arguments to Mongo's aggregation. Make these however you want.
    pipeline = [
      {
        $match:
          args
      },
      # Find the maximum quiz score for each user
      {
        $group:
          _id: { playerId: '$playerId', quizId: '$quizId' }
          # playerId: '$playerId'
          quizMax: { $max: '$score' }
      }
    ]

    db.collection("games").aggregate(
      pipeline,
      # Need to wrap the callback so it gets called in a Fiber.
      Meteor.bindEnvironment(
        (err, result) ->
          # Add each of the results to the subscription.
          _.each(result, (e) ->
            # Generate a random disposable id for aggregated documents
            sub.added("highscores", Random.id(),
              playerId: e._id
              score: e.pointSum
            )
          )
          sub.ready()
        ,
        (error) -> Meteor._debug( "Error doing aggregation: " + error)
      )
    )
