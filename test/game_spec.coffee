# test/game_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
utils     = require './utils'


test.describe "Game:", ->

  # hooks

  driver = undefined
  test.before ->
    driver = new webdriver.Builder()
      .withCapabilities(webdriver.Capabilities.chrome())
      .build()

    driver.manage().timeouts().implicitlyWait(1000)

    #driver.get "http://localhost:3000"

  test.after ->
    driver.quit()


  # tests

  describe "Player", ->

    test.it "should not see audio assets", ->
      utils.load_new_game(driver, 'ape')
        .then ->
          driver.findElements(css: 'audio')
            .then (elements) ->
              for element in elements
                element.getAttribute('controls')
                  .then (controls) ->
                    should.not.exist controls
                element.getCssValue('display')
                  .then (style) ->
                    style.should.be in ['none', 'hidden']


    test.it "should see a moving progress bar on audio playing", ->
      utils.load_new_game(driver, 'karlsen')
        .then ->
          old = { width: undefined, value: undefined }

          driver.findElement(id: 'asset-bar')
            .getAttribute('style')
            .then (value) ->
              old.width = value
          driver.findElement(id: 'asset-bar')
            .getText()
            .then (text) ->
              old.value = text

          driver.wait( ->
            driver.findElement(id: 'asset-bar')
              .getAttribute('style')
              .then (width) ->
                old.width != width
            driver.findElement(id: 'asset-bar')
              .getText()
              .then (text) ->
                old.value != text
          , 1500)


    test.it "should only be presented correct asset", ->
      utils.load_new_game(driver, 'apelape')
        .then ->
          driver.findElements(css: 'audio')
            .then (elements) ->
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

      utils.load_new_game(driver, 'joshua')
        .then( ->
          driver.findElement(css: '#heading')
            .getText()
            .then (text) ->
              first = text
              text.should.match /\d+\/\d+/)
        .then ->
          utils.answer_question(driver)
            .then ->
              driver.wait( ->
                driver.findElement(css: '#heading')
                  .getText()
                  .then (text) ->
                    text.should.match /\d+\/\d+/
                    unless text.match first
                      text.should.not.equal first
                      true
              , 2000)


    test.it "should be presented with score after ended game", ->
      utils.load_new_game(driver, 'whale')
        .then( -> utils.answer_question(driver, true))
        .then ->
          driver.findElement(css: '#ratio').getText()
            .then (text) ->
              text.should.match /Du fik \d+\/\d+ rigtige svar\!/
          driver.findElement(css: '#points').getText()
            .then (text) ->
              text.should.match /Point\: \d+/
