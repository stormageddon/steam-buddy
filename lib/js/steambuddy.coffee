request = require('request');
http = require('http');
Parser = require('./parser.js');
config = require('../../config.json');
parser = new Parser();
User = require('./user.js')
SlackIntegration = require('./integrations/slack_integration.js')
$q = require('q')
async = require('async')

STEAM_API_TOKEN = process.env.STEAM_API_TOKEN
BASE_STEAM_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key='
FULL_PLAYER_URL = BASE_STEAM_URL + process.env.STEAM_API_KEY + '&steamids='

integrations = []

init = ->
  console.log '##### Environment variables:'
  console.log '## Slack token:', process.env.SLACK_TOKEN
  console.log '## Steam API Key:', process.env.STEAM_API_KEY
  console.log '####################'
  integrations.push(new SlackIntegration({token: process.env.SLACK_TOKEN}, User))

  usersToCheck = []
  ((parseUser(user).then (result)-> usersToCheck.push(result)) for user in config.users)

  minutes = .1
  the_interval = minutes * 60 * 1000 #10 seconds
  setInterval( (=>
    getOnlineUsers(usersToCheck)
  ), the_interval)

sendNotifications = (user)->
  integration.sendNotification(user.name, user.currentGame) for integration in integrations

getOnlineUsers = (allUsers)->
  onlineUsers = []
  deferred = $q.defer()
  async.each allUsers, (user, callback)->
    isUserOnline(user).then (result)->
      onlineUsers.push(result) if result and not result.error
      callback()
  , (err)->
    sendNotifications(user) for user in onlineUsers if not err
    deferred.resolve(onlineUsers) if not err

  deferred.promise

isUserOnline = (user)->
  url = FULL_PLAYER_URL + user.id
  deferred = $q.defer()

  request url, (error, response, body)->
    if !error && response.statusCode is 200
      parsedResult = JSON.parse(body)
      player = parsedResult.response.players[0]

      return null if not player

      game = player.gameextrainfo

      if game and not user.isPlaying()
        user.setInGame(game)
        deferred.resolve(user)

      else if not game
        user.setInactive()
        deferred.resolve(null)
    else
      console.log 'An error was encountered at', Date.now()
      console.log 'status code:', response.statusCode
      console.log 'url:', url
      deferred.reject(error)

  deferred.promise

parseUser = (vanityName)->
  deferred = $q.defer()
  request "http://steamcommunity.com/id/#{vanityName}/?xml=1", (error, response, body)=>
    parser.parse body, (err, result)->
      deferred.resolve(new User({name: result.name, id: result.id})) if not err

  deferred.promise

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
