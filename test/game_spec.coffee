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

  start_game = ->
    driver.wait( ->
      driver.findElement(id: 'play')
        .getAttribute('disabled')
        .then (disabled) ->
          unless disabled
            true
    , 500)
      .then ->
        driver.findElement(id: 'play')
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

    test.it "should be able to enter name and display loading page", ->
      load_new_game 'karl'

      driver.findElement(id: 'heading')
        .getText()
        .then (text) ->
          assert text.match "Loading..."


    test.it "should see a moving progress bar on loading", ->
      load_new_game 'moby'

      old_value = undefined

      driver.findElement(id: 'loading-bar')
        .getAttribute('style')
        .then (value) ->
          old_value = value

      driver.wait( ->
        driver.findElement(id: 'loading-bar')
          .getAttribute('style')
          .then (value) ->
            old_value != value
      , 500)


    test.it "should not see audio assets", ->
      load_new_game('ape')
        .then(start_game)
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
        .then(start_game)
        .then ->
          old = { width: undefined, value: undefined }

          driver.findElement(id: 'audio-bar')
            .getAttribute('style')
            .then (value) ->
              old.width = value
          driver.findElement(id: 'audio-bar')
            .getText()
            .then (text) ->
              old.value = text

          driver.wait( ->
            driver.findElement(id: 'audio-bar')
              .getAttribute('style')
              .then (value) ->
                old.width != value
            driver.findElement(id: 'audio-bar')
              .getText()
              .then (text) ->
                old.value != text
          , 1500)


    # test.it "should only be presented correct asset", ->
    #   load_new_game('ape')
    #     .then(start_game)
    #     .then ->
    #       driver.findElements(css: 'audio')
    #         .then (elements) ->
    #           for element in elements
    #             element.then ->
    #               console.log driver.executeScript("$('audio#0')[0].paused")


    test.it "should be presented for multiple questions", ->
      first = undefined

      load_new_game('joshua')
        .then(start_game)
        .then ->
          driver.findElement(css: '#heading')
            .getText()
            .then (text) ->
              first = text
              console.log "first: #{text}"
              assert text.match /\d+\/\d+/
        # .then( -> answer_question false)
        .then ->
          driver.findElement(css: '#A.alternative').click()
            .then ->
              driver.wait( ->
                driver.findElement(css: '#heading')
                  .getText()
                  .then (text) ->
                    console.log "new: #{text}"
                    assert text.match /\d+\/\d+/
                    assert text != first
                    true
              , 1000)


    test.it "should be presented with score after ended game", ->
      load_new_game('joshua')
        .then(start_game)
        .then ->
          answer_question true
        .then ->
          driver.findElement(css: '#ratio').getText()
            .then (text) ->
              assert text.match /Du fik \d+\/\d+ rigtige svar\!/
          driver.findElement(css: '#points').getText()
            .then (text) ->
              assert text.match /Point\: \d+/
