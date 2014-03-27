# test/game_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
helpers   = require './helpers'


test.describe "Game:", ->

  driver = null

  # hooks

  test.before ->
    driver = new webdriver.Builder()
      .withCapabilities(webdriver.Capabilities.chrome())
      .build()
    driver.manage().timeouts().implicitlyWait(1000)

  test.after ->
    driver.quit()

  test.beforeEach ->
    driver.get "http://localhost:3000"

  test.afterEach ->
    driver.get "http://localhost:3000/logout"



  # tests

  describe "Player", ->

    test.it "should not see audio assets", ->
      helpers.startNewGame driver, 'ape'

      driver.findElements(css: 'audio').then (elements) ->
        for element in elements
          element.getAttribute('controls').then (controls) ->
            should.not.exist controls
          element.getCssValue('display').then (style) ->
            style.should.be in ['none', 'hidden']


    test.it "should see a moving progress bar on audio playing", ->
      old = { width: undefined, value: undefined }

      helpers.startNewGame driver, 'karlsen'

      driver.findElement(id: 'asset-bar').getAttribute('style')
        .then (value) ->
          old.width = value
      driver.findElement(id: 'asset-bar').getText()
        .then (text) ->
          old.value = text

      driver.wait( ->
        driver.findElement(id: 'asset-bar').getAttribute('style')
          .then (width) ->
            old.width isnt width
        driver.findElement(id: 'asset-bar').getText()
          .then (text) ->
            old.value isnt text
      , 1500)


    test.it "should only be presented correct asset", ->
      helpers.startNewGame driver, 'apelape'

      driver.findElements(css: 'audio').then (elements) ->
        driver.wait( ->
          for element,i in elements
            element.then ->
              driver.executeScript("return $('audio.asset')[#{i}].paused")
                .then (v) ->
                  if i is 0
                    v is true
                  else
                    v is false
        , 500)


    test.it "should be presented for multiple questions", ->
      first = undefined

      helpers.startNewGame driver, 'joshua'

      driver.findElement(css: '#heading').getText().then (text) ->
        first = text
        text.should.match /\d+\/\d+/

      helpers.answerQuestion(driver).then ->
        driver.wait( ->
          driver.findElement(css: '#heading').getText().then (text) ->
            text.should.match /\d+\/\d+/
            text.should.not.equal first
        , 2000)


    test.it "should be presented with score after ended game", ->
      helpers.startNewGame driver, 'whale'
      helpers.answerQuestion driver, all: true

      driver.findElement(css: '#ratio').getText().then (text) ->
        text.should.match /Du fik \d+\/\d+ rigtige svar\!/
      driver.findElement(css: '#points').getText().then (text) ->
        text.should.match /Point\: \d+/
