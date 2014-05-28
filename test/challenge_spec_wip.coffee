# test/challenge_spec.coffee

webdriverjs = require 'webdriverjs'
chai        = require 'chai'
expect      = chai.expect
helpers     = require './spec_helpers'


describe "Challenge:", ->


  # tests

  describe "Player", ->

    browser2 = {}
    browsers = [ browser, browser2 ]

    # hooks

    before (done) ->
      browser2 = webdriverjs.remote browser.options
      browser2.sessionId = browser.sessionId
      helpers.addCustomCommands(b) for b in [browser, browser2] #browsers
      browser2.init(done)

    beforeEach ->
      b.home() for b in [browser, browser2]

    afterEach ->
      b.logout() for b in [browser, browser2]

    after (done) ->
      browser2.end(done)


    # it 'testy', (done) ->
    #   # console.log browser
    #   # console.log ''
    #   # console.log browser2
    #   browser2.call done

    # it 'testy2', (done) ->
    #   # console.log browser
    #   # console.log ''
    #   # console.log browser2
    #   browser.call ->
    #     browser2.url('google.com')
    #     done()


    it "eventhandling", (done) ->
      browser
        .newPlayer({}, (err, username) ->
          browser2.emit 'challenge', username
        )
        .on 'checkChallenge', ->
          browser
            .refresh()
            .pause(500)
            .getText('#popup-confirm', (err, text) ->
              expect(err).to.be.null
              expect(text).to.match /accepter/i
            )
            .answerPopup(true)
            .pause(500)
            .answerPopup(true)
            .answerQuestions(all: true)
            # .call(done)

      browser2
        .on 'challenge', (username) ->
          browser2
            .newPlayer({})
            .newGame({challenge: username})
            .answerQuestions(all: true)
            .call(-> browser.emit 'checkChallenge')


    # it "should be notified when challenged", (done) ->
    #   browser
    #     .newPlayer({}, (err, username) ->
    #       browser.emit 'challenge', username
    #     )
    #     .on('checkChallenge', ->
    #       browser
    #         .refresh()
    #         .pause(500)
    #         .getText('#popup-confirm', (err, text) ->
    #           expect(err).to.be.null
    #           expect(text).to.match /accepter/i
    #         )
    #         .call done
    #       )

    #   browser2
    #     .on('challenge', (username) ->
    #       browser2
    #         .newPlayer({})
    #         .newGame({challenge: username})
    #         .answerQuestions(all: true)
    #         .call(-> browser2.emit 'checkChallenge')
    #     )


    # it "should be notified when challenged is declined", (done) ->
    #   browsers[0]
    #     .newPlayer({}, (err, username) ->
    #       browsers[1].emit 'challenge', username
    #     )
    #     .on('checkChallenge', ->
    #       browsers[0]
    #         .refresh()
    #         .pause(500)
    #         .getText('#popup-cancel', (err, text) ->
    #           expect(err).to.be.null
    #           expect(text).to.match /nej tak/i
    #         )
    #         .buttonClick('#popup-cancel', (err) ->
    #           expect(err).to.be.null
    #         )
    #         .call(-> browsers[1].emit 'declined')
    #       )
    #       .on('done', -> browsers[0].call done)

    #   browsers[1]
    #     .on('challenge', (username) ->
    #       browsers[1]
    #         .newPlayer({})
    #         .newGame({challenge: username})
    #         .answerQuestions(all: true)
    #         .call(-> browsers[0].emit 'checkChallenge')
    #     )
    #     .on('declined', ->
    #       browsers[1]
    #         .pause(2000)
    #         .getText('#opponentStatus', (err,text) ->
    #           expect(err).to.be.null
    #           expect(text).to.match /afvist din udfordring/i
    #         )
    #         .call(-> browsers[0].emit 'done')
    #       )


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
