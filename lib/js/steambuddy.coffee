request = require('request');
http = require('http');
config = require('../../config.json');
User = require('./user.js')
SlackIntegration = require('./integrations/slack_integration.js')
$q = require('q')

STEAM_API_TOKEN = process.env.STEAM_API_TOKEN

integrations = []
usersToCheck = []

init = ->
  console.log '##### Environment variables:'
  console.log '## Slack token:', process.env.SLACK_TOKEN
  console.log '## Steam API Key:', process.env.STEAM_API_KEY
  console.log '####################'
  integrations.push(new SlackIntegration({token: process.env.SLACK_TOKEN}, User))

  minutes = .1
  the_interval = minutes * 60 * 1000 #10 seconds
  setInterval( (=>
    tickIntegrations()
  ), the_interval)

tickIntegrations = ->
  integration.checkOnlineUsers() for integration in integrations

status = ->
  console.log 'Checking status of connections'
  deferred = $q.defer()
  $q.spread (integration.isConnected() for integration in integrations), (result)->
    console.log 'result:', result
    deferred.resolve(result)
  deferred.promise

module.exports =
  init: init
  status: status
