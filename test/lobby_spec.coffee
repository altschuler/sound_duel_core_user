# test/lobby_spec.coffee

chai = require 'chai'
expect = chai.expect
helpers = require('./spec_helpers')


describe "Lobby:", ->

  # hooks

  before ->
    helpers.addCustomCommands browser

  beforeEach ->
    browser.home()

  afterEach ->
    browser.logout()


  # tests

  describe "Player", ->

    it "should see game name", (done) ->
      browser
        .getText('#game-name', (err, text, hello) ->
          expect(err).to.be.null
          expect(text).to.match /Målsuppe/
        )
        .call done


    it "should see welcome message", (done) ->
      browser
        .getText('#welcome', (err, text) ->
          expect(err).to.be.null
          expect(text).to.match /Indtast dit navn og tryk \"Spil!\"/
        )
        .call done


    it "should recognizes brand", (done) ->
      browser
        .getCssProperty('#logo img', 'content', (err, src) ->
          expect(err).to.be.null
          expect(src).not.to.equal ''
        )
        .call done

    it "should be able to register with username", (done) ->
      username = null

      browser
        .newPlayer((err, newUsername) -> username = newUsername)
        .getValue('#username', (err, text) ->
          expect(err).to.be.null
          expect(text).to.equal username
        )
        .getText('div.alert', (err, text) ->
          expect(err).not.to.be.null
          expect(text).to.be.null
        )
        .getAttribute('#new-game', 'disabled', (err, res) ->
          expect(err).to.be.null
          expect(res).to.be.null
        )
        .call done

  # it "should be notified when username is already taken", (done) ->
  #   username = null

  #   browser
  #     .newPlayer((err, newUsername) ->
  #       console.log "callback 1 name: #{newUsername}"
  #       username = newUsername
  #     )
  #     .pause(1004)
  #     .logout()
  #     .pause(1000)
  #     # WTF: Bug with inserting variable as value?
  #     .addValue('input#username', username, (err) ->
  #       console.log 'wtf'
  #       expect(err).to.be.null
  #     )
  #     # .newPlayer(, (err, newUsername) ->
  #     #   console.log "callback 2 original name: #{username}"
  #     #   console.log "callback 2 name: #{newUsername}"
  #     #   expect(newUsername).to.be.equal username
  #     # )
  #     .waitFor('div.alert-error', 500, (err) ->
  #       expect(err).to.be.null
  #     )
  #     .getText('div.alert-error', (err, text) ->
  #       expect(err).to.be.null
  #       expect(text).to.match /username already taken/i
  #     )
  #     .call done
