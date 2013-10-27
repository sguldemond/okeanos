net = require 'net'

class Server

  constructor: (port) ->
    @stack = []
    @server = net.createServer()
    @server.on 'connection', (socket) =>
      socket.on 'data', @onData(socket)
    @server.listen port


  # Enclose the socket in the scope
  onData: (socket) =>
    return (data) =>
      # Parse messages and hand them over to the message handler
      messages = data.toString('utf-8').split('\n')
      for message in messages
        try
          message = JSON.parse message
          @messageHandler socket, message
        catch e

  # Respond to a message through a socket
  messageHandler: (socket, message) =>

    id = message.shift()

    # We only respond to a message if we have something to send to it
    # Else we just ignore the message
    if @stack.length

      # Get the first reply off the stack and make sure it is an array
      replies = @stack.shift()
      replies = if Array.isArray replies then replies else [replies]

      replies.forEach (reply, index) ->
        # We seperate replies by 100ms to give the client enough time
        # to handle each of them
        setTimeout ->
          output = JSON.stringify [id].concat reply
          output += '\n'
          socket.write output
        , index * 100

    else
      console.error 'message discarded', message


  # Adds messages to the reply stack
  replyWith: (messages) =>
    # Messages are added to the end of the stack
    messages = if Array.isArray messages then messages else [messages]
    @stack = @stack.concat messages

  # End the server
  destroy: (callback) =>
    @server.close callback

module.exports = Server