'use strict'

Hapi = require('hapi')
Steambuddy = require('./js/steambuddy.js')

server = new Hapi.Server()
server.connection(
  port: '9002'
)

server.route
  method: 'GET'
  path: '/lbstatus'
  handler: (req, reply)->
    Steambuddy.status().then (result)->
      console.log 'all connected?', result
      reply(statusCode: 200, message: 'OK') if result
      reply(statusCode: 204, message: 'Some services not responding') if not result

server.start (err)=>
  throw err if err
  console.log 'Server is running at:', server.info.uri
  Steambuddy.init()
