# test/challenge_spec.coffee

webdriverjs = require 'webdriverjs'
chai        = require 'chai'
expect      = chai.expect
helpers     = require './spec_helpers'


describe "Challenge:", ->

  browser_ = webdriverjs.remote( browser.options )
  browsers = [ browser, browser_ ]

  # hooks

  before (done) ->
    browsers[1].sessionId = browsers[0].sessionId
    helpers.addCustomCommands(b) for b in browsers
    browsers[1].init(done)

  beforeEach ->
    b.home() for b in browsers

  afterEach ->
    b.logout() for b in browsers

  after (done) ->
    browser_.end(done)

  # tests

  describe "Player", ->

    # it "testy", (done) ->
    #   console.log browsers[0]
    #   console.log ''
    #   console.log browsers[1]
    #   browsers[0]
    #     .newPlayer()
    #     .once('startGame', ->
    #       this.newGame({})
    #     )

    #   browsers[1]
    #     .newPlayer()
    #     .newGame({})
    #     .call( -> browsers[0].emit('startGame'))


    it "should be notified when challenged", ->
      username = null

      browsers[0]
        .newPlayer((err, newUsername) ->
          expect(err).to.be.null
          username = newUsername
        )
        # .waitFor('#popup-confirm', 10000, (err) ->
        #   expect(err).to.be.null
        #   this.getText('#popup-confirm', (err, text) ->
        #     console.log "text: #{text}"
        #     expect(text).to.match /aksepter/i
        #   )
        # )
        .on('checkChallenge', ->
          this.getText('#popup-confirm', (err, text) ->
            console.log "text: #{text}"
            expect(text).to.match /aksepter/i
          )
        )
        # .call done

      browsers[1]
        .newPlayer()
        .call(-> console.log "username: #{username}")
        .newGame((-> username), (err) ->
          expect(err).to.be.null
        )
        .answerQuestions(all: true)
        .call(-> browsers[0].emit(checkChallenge))


    # test.it "should be notified when challenged is declined", ->
    #   # ready driver
    #   helpers.initNewPlayer driver1, 'potter'

    #   # challenge
    #   helpers.startNewGame driver2, 'hagrid', challenge: 'potter'
    #   helpers.answerQuestion driver2, all: true

    #   # decline challenge
    #   helpers.answerPopup driver1, false

    #   # assert challenger is informed
    #   driver2.wait( ->
    #     driver2.findElement(id: 'opponentStatus').getText().then (text) ->
    #       return not text.match /endnu ikke svaret på din udfordring./i
    #   , 200)
    #   driver2.findElement(id: 'opponentStatus').getText().then (text) ->
    #     text.should.match /Din modstander har afvist din udfordring/i

    # test.it "should be notified of result when challenged is answered", ->
    #   challengerGameId = null

    #   # ready drivers
    #   helpers.initNewPlayer driver1, 'jens'

    #   # challenge and play game
    #   helpers.startNewGame driver2, 'lise', challenge: 'jens'
    #   helpers.answerQuestion driver2, all: true

    #   # store url and go to lobby
    #   driver2.getCurrentUrl().then (url) ->
    #     challengerGameId = url
    #   driver2.findElement(id: 'restart').click()

    #   # answer challenge
    #   helpers.answerPopup driver1, true
    #   driver1.wait( ->
    #     driver1.findElement id: 'popup-confirm'
    #   , 500)
    #   driver1.executeScript "setTimeout((function() {
    #     document.getElementById('popup-confirm').click();
    #   }), 750);"
    #   helpers.answerQuestion driver1, all:true

    #   # wait for popup
    #   driver2.wait( ->
    #     driver2.findElement(id: 'popup-confirm').getText().then (text) ->
    #       text.should.match /se resultat/i
    #   , 500)

    #   # se result and assert it's the same game
    #   helpers.answerPopup driver2, true
    #   driver2.wait( ->
    #     driver2.findElement(id: 'ratio')
    #   , 500)
    #   driver2.getCurrentUrl().then (url) ->
    #     url.should.match challengerGameId


    # test.it "should not be notified of seen result when", ->
    #   # ready drivers
    #   helpers.initNewPlayer driver1, 'alfred'

    #   # challenge and play game
    #   helpers.startNewGame driver2, 'magda', challenge: 'alfred'
    #   helpers.answerQuestion driver2, all: true

    #   # answer challenge
    #   helpers.answerChallenge driver1, true
    #   helpers.answerQuestion driver1, all:true

    #   # assert opponents score appears when answered
    #   driver2.findElement(id: 'opponentRatio').getText().then (text) ->
    #     text.should.match /.+ \d\/\d.+/i
    #   driver2.findElement(id: 'opponentPoints').getText().then (text) ->
    #     text.should.match /point: \d/i

    #   driver2.findElement(id: 'restart').click()
    #   driver2.findElement(id: 'popup-confirm').getText().then (text) ->
    #     text.should.not.match /aksepter/i


    # test.it "should see result when challenged is answered", ->
    #   # ready drivers
    #   helpers.initNewPlayer driver1, 'mobydick'

    #   # challenge and play game
    #   helpers.startNewGame driver2, 'dumbledor', challenge: 'mobydick'
    #   helpers.answerQuestion driver2, all: true

    #   # answer challenge
    #   helpers.answerChallenge driver1, true
    #   helpers.answerQuestion driver1, all:true

    #   # assert opponents result appears when answered
    #   driver1.findElement(id: 'opponentName').getText().then (text) ->
    #     text.should.match /dumbledor/i
    #   driver1.findElement(id: 'opponentRatio').getText().then (text) ->
    #     text.should.match /.+ \d+\/\d+.+/i
    #   driver1.findElement(id: 'opponentPoints').getText().then (text) ->
    #     text.should.match /point: \d+/i

    #   driver2.findElement(id: 'opponentName').getText().then (text) ->
    #     text.should.match /mobydick/i
    #   driver2.findElement(id: 'opponentRatio').getText().then (text) ->
    #     text.should.match /.+ \d+\/\d+.+/i
    #   driver2.findElement(id: 'opponentPoints').getText().then (text) ->
    #     text.should.match /point: \d+/i
