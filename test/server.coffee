net = require 'net'

class Server

  constructor: (port) ->
    @stack = []
    @server = net.createServer()
    @server.on 'connection', (socket) =>
      socket.on 'data', @onData(socket)
    @server.listen port


  onData: (socket) =>
    return (data) =>
      messages = data.toString('utf-8').split('\n')
      for message in messages
        try
          message = JSON.parse message
          @respond socket, message
        catch e

  respond: (socket, message) =>

    id = message.shift()

    if @stack.length

      replies = @stack.shift()
      replies = if Array.isArray replies then replies else [replies]

      replies.forEach (reply, index) ->
        setTimeout ->
          output = JSON.stringify [id].concat reply
          output += '\n'
          socket.write output
        , index * 100

    else
      console.error 'message discarded', message


  replyWith: (messages) =>
    messages = if Array.isArray messages then messages else [messages]
    @stack = @stack.concat messages

  destroy: (callback) =>
    @server.close callback

module.exports = Server