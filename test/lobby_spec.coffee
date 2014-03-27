# test/lobby_spec.coffee

should    = require 'should'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer
helpers   = require './helpers'


test.describe "Lobby:", ->

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

    test.it "should see game name", ->
      driver.findElement(css: 'h1:first-child').getText().then (text) ->
        text.should.match "Målsuppe"


    test.it "should see welcome message", ->
      driver.findElement(id: 'welcome').getText().then (text) ->
        text.should.match "Indtast dit navn og tryk \"Spil!\""


    test.it "should feel that DR recognizes the game", ->
      driver.findElement(css: 'div#logo>a>img').getAttribute('src')
        .then (src) ->
          src.should.match /.+dr-logo.svg/
