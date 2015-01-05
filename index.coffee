io = require('socket.io-client')
request = require('request')
open = require('open')
clipboard = require('copy-paste')

program = require('commander')

program
  .option '-l, --local', 'Local'
  .parse process.argv

server = if program.local then 'http://localhost:3000/'\
         else 'http://webcatio.herokuapp.com:80/'

request.post server, (err, res, body) ->
  console.log err if err
  console.log 'made request!'
  console.log 'body = ' + body

  id = body
  target = server + id
  # console.log 'target = ' + target
  
  clipboard.copy(target)
  socket = io.connect(target)
  open(target)
  socket.on 'connect', () ->
    # console.log 'connected to socket'

    process.stdin.setEncoding 'utf8'

    process.stdin.on 'readable', ->
      data = process.stdin.read()
      socket.emit 'data', data
