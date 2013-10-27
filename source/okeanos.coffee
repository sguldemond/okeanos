Client  = require './client'
window  = require './window'
screen  = require './screen'
util    = require './util'
wrapper = require './wrapper'
app     = require './app'
grid    = require './grid'
Stack   = require './stack'

class Okeanos

  constructor: (options = path: '/tmp/zephyros.sock') ->
    @client = new Client(options)
    wrapper._init @client

  bind: (key, modifier) =>
    stack = new Stack()
    @client
      .listen(0, 0, 'bind', key , modifier)
      .then undefined, undefined, stack.run
    return stack

  unbind: (key, modifier) =>
    @client.once 0, 'unbind', key, modifier

  listen: (event) =>
    stack = new Stack()
    @client
      .listen(0, 0, 'listen', event)
      .then undefined, undefined, stack.run
    return stack

  unlisten: (event) =>
    @client.once 0, 'unlisten', event

  app:    app
  util:   util
  window: window
  screen: screen
  grid:   grid

module.exports = Okeanos