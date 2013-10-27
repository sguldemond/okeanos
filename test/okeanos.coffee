assert = require 'assert'
Server = require './server'
Okeanos = require '../source/okeanos'

describe 'Okeanos', ->

  server = null

  options =
    port: 8124
    host: 'localhost'

  beforeEach ->
    server = new Server options.port

  afterEach ->
    server.destroy()

  it 'should bind a key shortcut twice', (done) ->
    $ = new Okeanos options

    server.replyWith [['-1', 'null']]

    $.bind('t', ['Cmd', 'Shift']).then ->
      done()

  it 'should bind to a key shortcut and execute calls outside of bind', (done) ->
    $ = new Okeanos options

    server.replyWith [['-1', 'null'], 'clip']

    $.bind('r', ['Cmd', 'Shift']).then ->

      $.util.clipboard().then (clip) ->
        assert.equal clip, 'clip'
        done()

  it 'should listen for two events', (done) ->
    $ = new Okeanos options

    server.replyWith [['-1', '77']]

    $.listen('window_created')
      .then (window) ->
        assert.equal window, 77
      .then ->
        done()