# app/client/utils/popup.coffee

# methods

# show popup dialog with text and options
@notify = (content) ->
  Session.set 'popup-content', content
  # insert popup template with data
  UI.insert UI.render(Template.popup), document.body
  # show dialog
  $('#popup').modal()


# helpers

Template.popup.helpers
  title: ->
    Session.get('popup-content').title
  content: ->
    Session.get('popup-content').content
  cancel: ->
    Session.get('popup-content').cancel
  confirm: ->
    Session.get('popup-content').confirm
