# app/client/utils/quizzes.coffee

# helpers

today = new Date()

Template.quizzes.helpers
  quizzes: ->
    Quizzes.find()

Template.quizRow.helpers
  today: ->
    @startDate < today and today < @endDate


# events

Template.quizRow.events
  'click [data-sd-startDate]': -> @startDate = today

  'click [data-sd-endDate]': ->
    console.log this
    Quizzes.update @_id,
      $set: { endDate: new Date(today.getTime() + 24*60*60*1000) }
