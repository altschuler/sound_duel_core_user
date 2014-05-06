# test/highscore_spec.coffee

chai    = require 'chai'
expect  = chai.expect
helpers = require './spec_helpers'


describe "Highscore:", ->

  # hooks

  before ->
    helpers.addCustomCommands browser

  beforeEach ->
    browser.home()

  afterEach ->
    browser.logout()


  # tests

  describe "Player", ->

    it "should be able to view highscore page", (done) ->
      browser
        .click('#highscores')
        .getText('#heading', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /highscore liste/i
        )
        .call done


    it "should see highscore after game", (done) ->
      username = null
      points = null
      found = false

      browser
        .newPlayer({}, (err, newUsername) ->
          expect(err).to.be.null
          username = newUsername
        )
        .newGame({})
        .answerQuestions(all: true)
        .getText('#ratio', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /du fik \d+\/\d+ rigtige svar\!/i
        )
        .getText('#points', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /point\: \d+/i
          points = text.match(/Point\: (\d+)/)[1]
        )
        .click('#restart')
        .click('#highscores')
        .getText('#heading', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /highscore liste/i
        )
        .elements('tr', (err, res) ->
          expect(err).to.be.null
          for e in res.value
            this.elementIdText(e.ELEMENT, (err, res) ->
              found = true if res.value.match new RegExp(username)
            )
        )
        .call( ->
          expect(found).to.be.true
        )
        .call done
