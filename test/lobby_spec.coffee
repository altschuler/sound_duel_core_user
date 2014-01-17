# test/google.coffee

assert    = require 'assert'
webdriver = require 'selenium-webdriver'
test      = require 'selenium-webdriver/testing'
server    = require('selenium-webdriver/remote').SeleniumServer


test.describe "Sound-Duel", ->
  driver = undefined
  test.before ->
    driver = new webdriver.Builder()
      .withCapabilities(webdriver.Capabilities.chrome())
      .build()

  test.it "should show loading title", ->
    driver.get "http://localhost:3000"
    driver.findElement(webdriver.By.id("myname")).sendKeys "moby"
    driver.findElement(webdriver.By.id("new_game")).click()
    driver.wait ->
      driver.findElement(webdriver.By.tagName('h3')).then (title) ->
        "Loading".match title
    , 1000

  test.after ->
    driver.quit()

