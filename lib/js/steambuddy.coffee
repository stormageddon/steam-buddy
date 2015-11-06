request = require('request');
http = require('http');
Parser = require('./parser.js');
config = require('../../config.json');
parser = new Parser();
SlackIntegration = require('./integrations/slack_integration.js')
User = require('./user.js')
$q = require('q')
async = require('async')

STEAM_API_TOKEN = process.env.STEAM_API_TOKEN
BASE_STEAM_URL = 'http://api.steampowered.com/ISteamUser/GetPlayerSummaries/v0002/?key='
PLAYER_SUMMARY_URL = BASE_STEAM_URL + process.env.STEAM_API_KEY + '&steamids='

integrations = []

init = ->
  integrations.push(new SlackIntegration({token: process.env.SLACK_TOKEN}))

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
      onlineUsers.push(result) if result
      callback()
  , (err)->
    sendNotifications(user) for user in onlineUsers if not err
    deferred.resolve(onlineUsers) if not err

  deferred.promise

isUserOnline = (user)->
  url = PLAYER_SUMMARY_URL + user.id
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
      console.log 'An error was encountered', error
      return error

  deferred.promise

parseUser = (vanityName)->
  deferred = $q.defer()
  request "http://steamcommunity.com/id/#{vanityName}/?xml=1", (error, response, body)=>
    parser.parse body, (err, result)->
      deferred.resolve(new User({name: result.name, id: result.id})) if not err

  deferred.promise

init()
