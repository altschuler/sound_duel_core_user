# test/helpers.coffee

startNewGame = (driver, name) ->
  driver.get "http://localhost:3000"

  driver.findElement(id: 'name').sendKeys name
  driver.findElement(id: 'new-game').click()

  # Selenium bug workaround
  # http://code.google.com/p/selenium/issues/detail?id=2766
  driver.wait( ->
    driver.findElement(id: 'popup-confirm')
  , 1000)
  driver.executeScript "setTimeout((function() {
      document.getElementById('popup-confirm').click();
    }), 250);"

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
            unless text.match /Resultat/
              answerQuestion driver, all: true
          true
        , 1000)

module.exports.startNewGame    = startNewGame
module.exports.answerQuestion = answerQuestion
