# test/lobby_spec.coffee

assert    = require 'assert'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer


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
          assert text.match "Målsuppe"


    test.it "should see welcome message", ->
      driver.findElement(id: 'welcome')
        .getText()
        .then (text) ->
          assert text.match "Indtast dit navn og tryk \"Spil!\""


    test.it "should feel that DR recognizes the game", ->
      driver.findElement(tagName: 'img')
        .getAttribute('src')
        .then (src) ->
          assert src.match 'logo'
