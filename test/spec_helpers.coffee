# test/spec_helpers.coffee

# constants

host = 'http://localhost:3000'
module.exports.host = host


# methods

answerPopup = (driver, answer) ->
  id = if answer then 'popup-confirm' else 'popup-cancel'

  # Selenium bug workaround
  # http://code.google.com/p/selenium/issues/detail?id=2766
  driver.wait( ->
    driver.findElement id: id
  , 500)
  driver.executeScript "setTimeout((function() {
    document.getElementById('#{id}').click();
  }), 250);"

module.exports.answerPopup = answerPopup


initNewPlayer = (driver, name) ->
  driver.findElement(id: 'name').sendKeys name
  driver.findElement(id: 'new-game').click()

  answerPopup driver, false

module.exports.initNewPlayer = initNewPlayer


logoutPlayer = (driver) ->
  driver.get "#{host}/session/logout"

module.exports.logoutPlayer = logoutPlayer


startNewGame = (driver, name, {challenge}={challenge:null}) ->
  driver.findElement(id: 'name').sendKeys name
  unless challenge
    driver.findElement(id: 'new-game').click()
  else
    driver.findElements(css: '.player').then (elements) ->
      for element in elements
        element.getText().then (text) ->
          if text is challenge then element.click()

  answerPopup driver, true

module.exports.startNewGame = startNewGame


answerChallenge = (driver, answer) ->
  answerPopup driver, answer

  if answer
    driver.wait( ->
      driver.findElement id: 'popup-confirm'
    , 500)
    driver.executeScript "setTimeout((function() {
      document.getElementById('popup-confirm').click();
    }), 750);"

module.exports.answerChallenge = answerChallenge


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

module.exports.answerQuestion = answerQuestion


# hooks

module.exports.after = (drivers) ->
  driver.quit() for driver in drivers

module.exports.afterEach = (drivers) ->
  logoutPlayer driver for driver in drivers

module.exports.beforeEach = (drivers) ->
  driver.get host for driver in drivers
