# helpers
Template.quizzes.helpers
  quizzes: ->
    Quizzes.find()

Template.quizRow.helpers
  today: ->
    today = new Date()
    @startDate < today and today < @endDate


today = new Date()

Template.quizRow.events
  'click [data-sd-startDate]': -> @startDate = today
  'click [data-sd-endDate]': ->
    console.log this
    # Quizzes.findOne(@_id).update(bb
    Quizzes.update(@_id,
      '$set':
        endDate: new Date(today.getTime() + 24*60*60*1000)
    )
