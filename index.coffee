io = require('socket.io-client')
request = require('request')
open = require('open')
clipboard = require('copy-paste')
util = require('util')
convert = require('ansi-to-html')
converter = new convert()

savedStdin = ""

process.stdin.on 'data', (data) ->
  savedStdin += data

program = require('commander')

program
  .option '-l, --local', 'Local'
  .parse process.argv

server = if program.local then 'http://localhost:3000/'\
         else 'http://webcatio.herokuapp.com:80/'

request.post server, (err, res, body) ->
  # console.log err if err
  # console.log 'made request!'
  # console.log 'body = ' + body

  id = body
  target = server + id
  targetForOutput = target.replace ":80", ""
  # console.log 'target = ' + target

  clipboard.copy(target)
  socket = io.connect(target)
  open(target)
  socket.on 'connect', () ->
    # console.log 'connected to socket'

    process.stdin.setEncoding 'utf8'
    # process.stdin.resume()
    
    console.log "STREAM " + id
    console.log "To view stream, visit " + targetForOutput
    console.log "This link is also copied to the clipboard"

    setTimeout(->
      socket.emit 'data', processData savedStdin
    , 1000)

    process.stdin.on 'data', (data) ->
      if data
        data = processData data
      socket.emit 'data', data

    process.on 'SIGINT', ->
      console.log '\nexiting...'
      socket.emit 'exit', ''
      process.exit 2

processData = (data) ->
  data = data
        .split " "
        .join "&nbsp;"
        .split "\n"
        .join "<br />"
  data = converter.toHtml(data)
  data
