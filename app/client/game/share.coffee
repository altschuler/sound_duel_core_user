# app/client/game/share.coffee

Template.socialshare.helpers
  # substr to get rid of the leading slash
  url: ->
    switch @what
      when "game"
        Meteor.absoluteUrl(Router.current().path.substr(1))
      when "quiz"
        "#{Meteor.absoluteUrl()}quiz/#{currentQuizId()}"
