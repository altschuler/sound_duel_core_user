# test/highscore_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
utils     = require './utils'


test.describe "Highscore:", ->

  # hooks

  driver = undefined
  test.before ->
    driver = new webdriver.Builder()
      .withCapabilities(webdriver.Capabilities.chrome())
      .build()

    driver.manage().timeouts().implicitlyWait(1000)

    driver.get "http://localhost:3000"

  test.after ->
    driver.quit()


  # tests

  describe "Player", ->

    test.it "should be able to view highscore page", ->
      driver.findElement(id: 'highscores').click()
      driver.findElement(id: 'heading').getText()
        .then( (text) ->
          text.should.match /Highscore liste/)

    test.it "should see highscore after game", ->
      utils.load_new_game(driver, 'askeladden')
        .then( -> utils.answer_question(driver, true))
        driver.findElement(css: '#ratio').getText()
          .then (text) ->
            text.should.match /Du fik \d+\/\d+ rigtige svar\!/
        driver.findElement(css: '#points').getText()
          .then (text) ->
            text.should.match /Point\: \d+/
