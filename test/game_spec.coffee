# test/game_spec.coffee

chai    = require 'chai'
expect  = chai.expect
helpers = require './spec_helpers'


describe "Game:", ->

  # hooks

  before ->
    helpers.addCustomCommands browser

  beforeEach ->
    browser.home()

  afterEach ->
    browser.logout()


  # tests

  describe "Player", ->

    it "should not see audio assets", (done) ->
      browser
        .newPlayer({})
        .newGame({})
        .getAttribute('audio', 'controls', (err, res) ->
          expect(err).to.be.null
          expect(res).to.be.null
        )
        .getCssProperty('audio', 'display', (err, res) ->
          expect(err).to.be.null
          expect(res).to.equal 'none'
        )
        .call done


    it "should see a moving progress bar on audio playing", (done) ->
      old = { width: null, value: null }

      browser
        .newPlayer({})
        .newGame({})
        .getCssProperty('#asset-bar', 'width', (err, res) ->
          expect(err).to.be.null
          expect(res).not.to.be.null
          old.with = res
        )
        .getText('#asset-bar', (err, text) ->
          expect(err).to.be.null
          expect(text).not.to.be.null
          old.text = text
        )
        .pause(500)
        .getCssProperty('#asset-bar', 'width', (err, res) ->
          expect(err).to.be.null
          expect(res).not.to.equal old.width
        )
        .getText('#asset-bar', (err, text) ->
          expect(err).to.be.null
          expect(text).not.to.equal old.text
        )
        .call done


    it "should only be presented correct asset", (done) ->
      browser
        .newPlayer({})
        .newGame({})
        .execute("return document.querySelectorAll('audio').length",
          (err, res) ->
            expect(err).to.be.null
            numOfAudios = res.value
        )
        .pause(1000)
        .elements('audio', (err, res) ->
          first = true
          for i in res.value
            this.elementIdAttribute(i.ELEMENT, 'paused', (err, res) ->
              expect(err).to.be.null
              paused = res.value
              if first
                first = false
                expect(paused).to.be.null
              else
                expect(paused).to.be.equal 'true'
            )
        )
        .call done


    it "should be presented for multiple questions", (done) ->
      first = null

      browser
        .newPlayer({})
        .newGame({})
        .getText('.panel-title', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /\d+\/\d+/
          first = text
        )
        .answerQuestions(all: false)
        .pause(500)
        .getText('.panel-title', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /\d+\/\d+/
          expect(text).not.to.equal first
        )
        .call done


    it "should be presented with score after ended game", (done) ->
      browser
        .newPlayer({})
        .newGame({})
        .answerQuestions(all: true)
        .getText('#ratio', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /du fik \d+\/\d+ rigtige svar\!/i
        )
        .getText('#points', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /point\: \d+/i
        )
        .call done
