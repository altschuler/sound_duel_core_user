# test/highscore_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
helpers   = require './helpers'


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
      driver.findElement(id: 'heading').getText().then (text) ->
        text.should.match /Highscore liste/


    test.it "should see highscore after game", ->
      points = undefined

      helpers.startNewGame driver, 'askeladden'
      helpers.answerQuestion driver, all: true

      driver.findElement(css: '#ratio').getText().then (text) ->
        text.should.match /Du fik \d+\/\d+ rigtige svar\!/
      driver.findElement(css: '#points').getText().then (text) ->
        points = text.match(/Point\: (\d+)/)[1]

      driver.findElement(css: '#restart').click()

      driver.findElement(css: '#highscores').click()
      driver.findElement(css: '#heading').getText().then (text) ->
        text.should.match /Highscore liste/

      driver.findElements(tagName: 'tr').then (elements) ->
        for element in elements
          element.getText().then (text) ->
            if text.match /askeladden.*/
              text[2..].should.match "askeladden #{points}"
              return
