# test/helpers.coffee

# Selenium bug workaround
# http://code.google.com/p/selenium/issues/detail?id=2766
answerPopup = (driver, answer) ->
  id = if answer then 'popup-confirm' else 'popup-cancel'

  driver.wait( ->
    driver.findElement id: id
  , 500)
  driver.executeScript "setTimeout((function() {
    document.getElementById('#{id}').click();
  }), 250);"


initNewPlayer = (driver, name) ->
  driver.findElement(id: 'name').sendKeys name
  driver.findElement(id: 'new-game').click()

  answerPopup driver, false


startNewGame = (driver, name, {challengee}={challengee:null}) ->
  driver.findElement(id: 'name').sendKeys name
  unless challengee
    driver.findElement(id: 'new-game').click()
  else
    driver.findElements(css: '.player').then (elements) ->
      for element in elements
        element.getText().then (text) ->
          if text is challengee then element.click()

  answerPopup driver, true


answerChallenge = (driver, answer) ->
  answerPopup driver, answer

  if answer
    driver.wait( ->
      driver.findElement id: 'popup-confirm'
    , 500)
    driver.executeScript "setTimeout((function() {
      document.getElementById('popup-confirm').click();
    }), 750);"


answerQuestion = (driver, {all}={all:false}) ->
  driver.findElements(css: '.alternative').then (elements) ->
    driver.wait( ->
      elements[0].getAttribute('disabled').then (disabled) ->
        unless disabled
          elements[0].click()
          true
    , 2000).then ->
      if all
        driver.wait( ->
          driver.findElement(id: 'heading').getText().then (text) ->
            unless text.match /resultat/i
              answerQuestion driver, all: true
          true
        , 1000)


module.exports.answerPopup     = answerPopup
module.exports.initNewPlayer   = initNewPlayer
module.exports.startNewGame    = startNewGame
module.exports.answerChallenge = answerChallenge
module.exports.answerQuestion  = answerQuestion
