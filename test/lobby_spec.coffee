# test/lobby_spec.coffee

webdriverjs = require 'webdriverjs'
chai = require 'chai'
should = chai.should()
expect = chai.expect


describe "Lobby:", ->

  # hooks

  beforeEach ->
    browser.url('localhost:3000')

  after (done) ->
    browser.end(done)


  # tests

  describe "Player", ->

    it "should see game name", (done) ->
      browser
        .getText('#game-name', (err, text) ->
          expect(err).to.be.null
          text.should.match /Målsuppe/
        )
        .call done


    it "should see welcome message", (done) ->
      browser
        .getText('#welcome', (err, text) ->
          expect(err).to.be.null
          text.should.match /Indtast dit navn og tryk \"Spil!\"/
        )
        .call done


    it "should feel that DR recognizes the game", (done) ->
      browser
        .getCssProperty('#logo img', 'content', (err, src) ->
          expect(err).to.be.null
          src.should.match /.+dr-logo.svg/
        )
        .call done
