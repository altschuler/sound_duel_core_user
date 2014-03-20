# test/lobby_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
utils     = require './helpers'


test.describe "Lobby:", ->

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

    test.it "should see game name", ->
      driver.findElement(tagName: 'h1')
        .getText()
        .then (text) ->
          text.should.match "Målsuppe"


    test.it "should see welcome message", ->
      driver.findElement(id: 'welcome')
        .getText()
        .then (text) ->
          text.should.match "Indtast dit navn og tryk \"Spil!\""


    test.it "should feel that DR recognizes the game", ->
      driver.findElement(tagName: 'img')
        .getAttribute('src')
        .then (src) ->
          src.should.match /.+dr-logo.svg/
