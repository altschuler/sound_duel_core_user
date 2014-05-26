# app/client/utils/popup.coffee

# methods

# show popup dialog with text and options
@notify = (content) ->
  Session.set 'popup-content', content
  # show dialog
  $('#popup').modal({
    keyboard: false
  })

content = ->
  Session.get('popup-content')
# helpers

Template.popup.helpers
  title: ->
    content().title if content()
  content: ->
    content().content if content()
  cancel: ->
    content().cancel if content()
  confirm: ->
    content().confirm if content()
