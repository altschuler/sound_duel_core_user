# test/utils.coffee

load_new_game = (driver, name) ->
  driver.get "http://localhost:3000"
  driver.findElement(id: 'name')
    .sendKeys name
  driver.findElement(id: 'new-game')
    .click()

answer_question = (driver, all) ->
  driver.findElements(css: '.alternative')
    .then (elements) ->
      elements[0].click()
      driver.wait( ->
        if all
          driver.findElement(tagName: 'h3')
            .getText()
            .then (text) ->
              unless text.match /Resultater/
                answer_question driver, true
        true
      , 1000)

module.exports.load_new_game   = load_new_game
module.exports.answer_question = answer_question
