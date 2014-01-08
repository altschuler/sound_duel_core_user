# tests/players_test.coffee

assert = require 'assert'

suite 'Players', ->
  test 'in the server', (done, server) ->
    server.eval ->
      Players.insert title: 'hello there'
      players = Players.find().fetch()
      emit('players', players)

    server.once 'players', (players) ->
      assert.equal 1, players.length
      done()
