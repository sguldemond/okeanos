Okeanos = require '../source/okeanos'
assert   = require 'assert'
Server   = require './server'

describe 'Window', ->

  server = null

  options =
    port: 8124
    host: 'localhost'

  beforeEach ->
    server = new Server options.port

  afterEach ->
    server.destroy()

  it 'should get the focused window', (done) ->

    $ = new Okeanos options

    server.replyWith '1'

    $.window.active().then (win) ->
      assert.equal win.id, 1
      done()

  it 'should get all the windows', (done) ->

    $ = new Okeanos options

    # [ container [ replies [ arguments [ content ]]]]
    server.replyWith [[[ [1, 2, 3, 4] ]]]

    $.window.all().then (windows) ->
      assert.equal windows.length, 4
      done()

  it 'should get the window title', (done) ->

    $ = new Okeanos options

    server.replyWith '1',

    $.window.active().then (win) ->
      assert.equal win.id, 1

      server.replyWith 'Window title'

      win.getTitle().then (title) ->
        assert.equal title, 'Window title'
        done()

  it 'should preload load multiple parameters', (done) ->

    $ = new Okeanos options

    server.replyWith [1, 'Title', no]

    $.window.active().then (win) ->
      assert.equal win.id, 1

      win.preload('title', 'normal').then (win) ->
        assert.equal win.title, 'Title'
        assert.equal win.normal, no
        done()
