# test/game_spec.coffee

assert    = require 'assert'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer


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


  # methods

  load_new_game = (name) ->
    driver.get "http://localhost:3000"
    driver.findElement(id: 'name')
      .sendKeys name
    driver.findElement(id: 'new_game')
      .click()

  answer_question = (all) ->
    driver.findElements(css: '.alternative')
      .then (elements) ->
        elements[0].click()
        driver.wait( ->
          if all
            driver.findElement(tagName: 'h3')
              .getText()
              .then (text) ->
                unless text.match /Resultater/
                  answer_question true
          true
        , 1000)


  # tests

  describe "Player", ->

    test.it "should not see audio assets", ->
      load_new_game('ape')
        .then ->
          driver.findElements(css: 'audio')
            .then (elements) ->
              for element in elements
                element.getAttribute('controls')
                  .then (controls) ->
                    assert !controls
                element.getCssValue('display')
                  .then (style) ->
                    assert style in ['none', 'hidden']


    test.it "should see a moving progress bar on audio playing", ->
      load_new_game('karlsen')
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
      load_new_game('ape')
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

      load_new_game('joshua')
        .then( ->
          driver.findElement(css: '#heading')
            .getText()
            .then (text) ->
              first = text
              assert text.match /\d+\/\d+/)
        .then ->
          driver.findElement(css: '#A.alternative').click()
            .then ->
              driver.wait( ->
                driver.findElement(css: '#heading')
                  .getText()
                  .then (text) ->
                    assert text.match /\d+\/\d+/
                    assert text != first
                    true
              , 1000)


    test.it "should be presented with score after ended game", ->
      load_new_game('joshua')
        .then( ->
          answer_question true)
        .then ->
          driver.findElement(css: '#ratio').getText()
            .then (text) ->
              assert text.match /Du fik \d+\/\d+ rigtige svar\!/
          driver.findElement(css: '#points').getText()
            .then (text) ->
              assert text.match /Point\: \d+/
