# test/highscore_spec.coffee

webdriverjs = require 'webdriverjs'
chai = require 'chai'
should = chai.should()
expect = chai.expect
helpers = require('./spec_helpers')


describe "Highscore:", ->

  # hooks

  before ->
    helpers.addCustomCommands browser

  beforeEach ->
    browser.url('localhost:3000')

  after (done) ->
    browser.end(done)


  # tests

  describe "Player", ->

    it "should be able to view highscore page", (done) ->
      browser
        .click('#highscores')
        .getText('#heading', (err, text) ->
          expect(err).to.be.null
          text.should.match /Highscore liste/
        )
        .call done

    it "should see highscore after game", (done) ->
      points = null

      browser
        .startNewGame('askeladden', {challenge:null})
        .answerQuestion(all: true)
        .call(-> console.log "done answering")
        .getText('#ratio', (err, text) ->
          expect(err).to.be.null
          text.should.match /Du fik \d+\/\d+ rigtige svar\!/
        )
        .getText('#points', (err, text) ->
          expect(err).to.be.null
          points = text.match(/Point\: (\d+)/)[1]
        )
        .click('#restart')
        .click('#highscores')
        .getText('#heading', (err, text) ->
          expect(err).to.be.null
          text.should.match /Highscore liste/
        )
        # .getText('tr:last', (err, res) ->
        #   console.log res
        # )
        .call done
