# test/spec_helpers.coffee

webdriverjs = require 'webdriverjs'
# chai = require 'chai'
# should = chai.should()
# expect = chai.expect


# methods

host = 'http://localhost:3000'


home = (callback) ->
  this.url host, (err) -> callback err


answerPopup = (answer, callback) ->
  id = if answer then '#popup-confirm' else '#popup-cancel'

  this
    .waitFor(id, 500)
    .pause(500)
    .click(id, (err) ->
      callback(err)
    )

    # Selenium bug workaround
    # http://code.google.com/p/selenium/issues/detail?id=2766
    # .execute("setTimeout((function() {
    #   document.getElementById('#{id}').click();
    # }), 250);", (err) ->
    #   console.log "answerPopup callback\n#{err}")


initNewPlayer = (name, callback) ->
  this
    .setValue('#name', name)
    .click('#new-game')
    .answerPopup(false, (err) -> callback err)


logout = (callback) ->
  this.url "#{host}/session/logout", (err) -> callback err


startNewGame = (name, {challenge}={challenge:null}, callback) ->
  this
    .setValue('#name', name)
    .call(->
      if challenge?
        this.click(".player:contains(#{challenge})")
      else
        this.click('#new-game')
    )
    .answerPopup(true, (err) -> callback err)


answerChallenge = (answer, callback) ->
  this.answerPopup(answer, (err) -> callback(err))

  # if answer
  #   driver.wait( ->
  #     driver.findElement id: 'popup-confirm'
  #   , 500)
  #   driver.executeScript "setTimeout((function() {
  #     document.getElementById('popup-confirm').click();
  #   }), 750);"


answerQuestion = ({all}={all:false}, callback) ->
  this
    # .waitFor('button.alternative:enabled', 2000, (err) ->
    #   #expect(err).to.be.null
    #   console.log 'finished waiting'
    #   this.buttonClick('.alternative:first')
    # )
    .pause(2000, ->
      this.getAttribute('.alternative:first', 'disabled', (err, res) ->
        if res
          throw new Error('button.alternative not clickable (disabled)')
        else
          this.execute("$('.alternative:first').click()")
      )
    )
    # .buttonClick('button.alternative:first', (err) ->
    #   expect(err).to.be.null
    # )
    .call(->
      if all
        this.url((err, res) ->
          if res.value.match /.*\/result/
            callback err
          else
            this.pause(250, -> this.answerQuestion all: true)
        )
    )
    .call callback


# export

commands = [
  { name: 'home',            fn: home }
  { name: 'answerPopup',     fn: answerPopup }
  { name: 'initNewPlayer',   fn: initNewPlayer }
  { name: 'logout',          fn: logout }
  { name: 'startNewGame',    fn: startNewGame }
  { name: 'answerChallenge', fn: answerChallenge }
  { name: 'answerQuestion',  fn: answerQuestion }
]

module.exports.addCustomCommands = (browser) ->
  browser.addCommand(cmd.name, cmd.fn) for cmd in commands
