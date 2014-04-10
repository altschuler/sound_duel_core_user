# test/challenge_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
helpers   = require './spec_helpers'


test.describe "Challenge:", ->

  driver1 = null
  driver2 = null

  # hooks

  test.before ->
    driver1 = new webdriver.Builder()
      .withCapabilities(webdriver.Capabilities.chrome())
      .build()
    driver1.manage().timeouts().implicitlyWait(1000)

    driver2 = new webdriver.Builder()
      .withCapabilities(webdriver.Capabilities.chrome())
      .build()
    driver2.manage().timeouts().implicitlyWait(1000)

  test.after -> helpers.after [driver1, driver2]

  test.beforeEach -> helpers.beforeEach [driver1, driver2]

  test.afterEach -> helpers.afterEach [driver1, driver2]


  # tests

  describe "Player", ->

    test.it "should be notified when challenged", ->
      # ready driver
      helpers.initNewPlayer driver1, 'harry'

      # challenge and go to lobby
      helpers.startNewGame driver2, 'ron', challenge: 'harry'
      helpers.answerQuestion driver2, all: true
      driver2.findElement(id: 'restart').click()

      # assert popup appears with challenge
      driver1.wait( ->
        driver1.findElement(id: 'popup-confirm').getText().then (text) ->
          text.should.match /aksepter/i
      , 500)

    test.it "should be notified when challenged is declined", ->
      # ready driver
      helpers.initNewPlayer driver1, 'potter'

      # challenge
      helpers.startNewGame driver2, 'hagrid', challenge: 'potter'
      helpers.answerQuestion driver2, all: true

      # decline challenge
      helpers.answerPopup driver1, false

      # assert challenger is informed
      driver2.wait( ->
        driver2.findElement(id: 'opponentStatus').getText().then (text) ->
          return not text.match /endnu ikke svaret på din udfordring./i
      , 200)
      driver2.findElement(id: 'opponentStatus').getText().then (text) ->
        text.should.match /Din modstander har afvist din udfordring/i

    test.it "should be notified of result when challenged is answered", ->
      challengerGameId = null

      # ready drivers
      helpers.initNewPlayer driver1, 'jens'

      # challenge and play game
      helpers.startNewGame driver2, 'lise', challenge: 'jens'
      helpers.answerQuestion driver2, all: true

      # store url and go to lobby
      driver2.getCurrentUrl().then (url) ->
        challengerGameId = url
      driver2.findElement(id: 'restart').click()

      # answer challenge
      helpers.answerPopup driver1, true
      driver1.wait( ->
        driver1.findElement id: 'popup-confirm'
      , 500)
      driver1.executeScript "setTimeout((function() {
        document.getElementById('popup-confirm').click();
      }), 750);"
      helpers.answerQuestion driver1, all:true

      # wait for popup
      driver2.wait( ->
        driver2.findElement(id: 'popup-confirm').getText().then (text) ->
          text.should.match /se resultat/i
      , 500)

      # se result and assert it's the same game
      helpers.answerPopup driver2, true
      driver2.wait( ->
        driver2.findElement(id: 'ratio')
      , 500)
      driver2.getCurrentUrl().then (url) ->
        url.should.match challengerGameId


    test.it "should not be notified of seen result when", ->
      # ready drivers
      helpers.initNewPlayer driver1, 'alfred'

      # challenge and play game
      helpers.startNewGame driver2, 'magda', challenge: 'alfred'
      helpers.answerQuestion driver2, all: true

      # answer challenge
      helpers.answerChallenge driver1, true
      helpers.answerQuestion driver1, all:true

      # assert opponents score appears when answered
      driver2.findElement(id: 'opponentRatio').getText().then (text) ->
        text.should.match /.+ \d\/\d.+/i
      driver2.findElement(id: 'opponentPoints').getText().then (text) ->
        text.should.match /point: \d/i

      driver2.findElement(id: 'restart').click()
      driver2.findElement(id: 'popup-confirm').getText().then (text) ->
        text.should.not.match /aksepter/i


    test.it "should see result when challenged is answered", ->
      # ready drivers
      helpers.initNewPlayer driver1, 'mobydick'

      # challenge and play game
      helpers.startNewGame driver2, 'dumbledor', challenge: 'mobydick'
      helpers.answerQuestion driver2, all: true

      # answer challenge
      helpers.answerChallenge driver1, true
      helpers.answerQuestion driver1, all:true

      # assert opponents result appears when answered
      driver1.findElement(id: 'opponentName').getText().then (text) ->
        text.should.match /dumbledor/i
      driver1.findElement(id: 'opponentRatio').getText().then (text) ->
        text.should.match /.+ \d+\/\d+.+/i
      driver1.findElement(id: 'opponentPoints').getText().then (text) ->
        text.should.match /point: \d+/i

      driver2.findElement(id: 'opponentName').getText().then (text) ->
        text.should.match /mobydick/i
      driver2.findElement(id: 'opponentRatio').getText().then (text) ->
        text.should.match /.+ \d+\/\d+.+/i
      driver2.findElement(id: 'opponentPoints').getText().then (text) ->
        text.should.match /point: \d+/i